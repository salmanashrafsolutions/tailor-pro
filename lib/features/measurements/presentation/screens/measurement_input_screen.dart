import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/core/database/app_database.dart';
import 'package:tailor_pro/core/widgets/fractional_keypad.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/customers/models/customer_model.dart';
import 'package:tailor_pro/features/measurements/models/measurement_model.dart';
import 'package:tailor_pro/features/measurements/presentation/widgets/custom_option_dialog.dart';
import 'package:tailor_pro/features/measurements/presentation/screens/sketch_canvas_screen.dart';

class MeasurementInputScreen extends ConsumerStatefulWidget {
  final CustomerModel customer;
  final MeasurementModel? initialMeasurement; // if editing or viewing

  const MeasurementInputScreen({
    super.key,
    required this.customer,
    this.initialMeasurement,
  });

  @override
  ConsumerState<MeasurementInputScreen> createState() => _MeasurementInputScreenState();
}

class _MeasurementInputScreenState extends ConsumerState<MeasurementInputScreen> with SingleTickerProviderStateMixin {
  late TabController _garmentTabController;
  final _uuid = const Uuid();

  String _currentUnit = 'inch'; // 'inch' or 'cm'
  String _activeFieldKey = 'length';
  final Map<String, TextEditingController> _controllers = {};

  // Selected Style options
  final Map<String, String> _selectedStyles = {};

  // Dynamic custom options fetched from database
  final Map<String, List<String>> _categoryOptions = {
    'collar_band': ['مکمل بین (فل بین)', 'ہاف بین', 'شرٹ کالر', 'کٹ بین', 'چائنیز بین'],
    'front_patti': ['گم پٹی', 'سامنے کاج پٹی', 'سادہ کرتا پٹی', 'زپ والی پٹی'],
    'cuff_style': ['سنگل کف', 'ڈبل کف', 'فرینچ کف', 'گول کف', 'کٹ کف', 'کھلا بازو (سادہ)'],
    'pocket_style': ['1 سامنے جیب', '2 سامنے جیبیں', 'بغیر سامنے جیب'],
    'side_pocket': ['1 سائیڈ جیب', '2 سائیڈ جیبیں'],
    'daman_style': ['چورس دامن (سیدھا)', 'گول دامن'],
  };

  final _extraNotesController = TextEditingController();
  bool _isSaving = false;
  String? _sketchPath;

  final List<Map<String, String>> _garmentTypes = [
    {'key': 'shalwar_kameez', 'ur': 'شلوار قمیض', 'en': 'Shalwar Kameez'},
    {'key': 'kurta', 'ur': 'کرتا', 'en': 'Kurta'},
    {'key': 'waistcoat', 'ur': 'ویسٹ کوٹ', 'en': 'Waistcoat'},
    {'key': 'sherwani', 'ur': 'شیروانی', 'en': 'Sherwani'},
    {'key': 'pant_shirt', 'ur': 'پینٹ شرٹ', 'en': 'Pant Shirt'},
    {'key': 'coat_suit', 'ur': 'کوٹ سوٹ', 'en': 'Coat Suit'},
    {'key': 'ladies_suit', 'ur': 'لیڈیز سوٹ', 'en': 'Ladies Suit'},
  ];

  final List<Map<String, String>> _kameezFields = [
    {'key': 'length', 'ur': 'لمبائی قمیض', 'en': 'Kameez Length'},
    {'key': 'chest', 'ur': 'چھاتی', 'en': 'Chest'},
    {'key': 'waist', 'ur': 'کمر', 'en': 'Waist'},
    {'key': 'hip', 'ur': 'ہپ', 'en': 'Hip'},
    {'key': 'shoulder_teera', 'ur': 'تیرا (شولڈر)', 'en': 'Shoulder'},
    {'key': 'sleeve_arm', 'ur': 'بازو (آستین)', 'en': 'Sleeve'},
    {'key': 'collar_neck', 'ur': 'گلا / کالر', 'en': 'Collar / Neck'},
    {'key': 'ghera', 'ur': 'دامن / گھیرا', 'en': 'Ghera / Flare'},
    {'key': 'shalwar_length', 'ur': 'لمبائی شلوار', 'en': 'Shalwar Length'},
    {'key': 'paincha', 'ur': 'پائنچہ', 'en': 'Paincha'},
    {'key': 'asan', 'ur': 'آسن', 'en': 'Asan'},
    {'key': 'thigh_ran', 'ur': 'ران', 'en': 'Thigh'},
  ];

  @override
  void initState() {
    super.initState();
    _garmentTabController = TabController(length: _garmentTypes.length, vsync: this);

    // Initialize text controllers for all fields
    for (final f in _kameezFields) {
      _controllers[f['key']!] = TextEditingController();
    }

    _loadExistingMeasurement();
    _loadCustomOptions();
  }

  void _loadExistingMeasurement() {
    if (widget.initialMeasurement != null) {
      final m = widget.initialMeasurement!;
      _currentUnit = m.unit;
      m.measurements.forEach((k, v) {
        if (_controllers.containsKey(k)) {
          _controllers[k]!.text = v.toString();
        }
      });
      m.styleOptions.forEach((k, v) {
        _selectedStyles[k] = v.toString();
      });
      _extraNotesController.text = m.extraDetailsText ?? '';
      _sketchPath = m.sketchSvgPath;
    }
  }

  Future<void> _loadCustomOptions() async {
    final activeBiz = ref.read(businessProvider).activeBusiness;
    if (activeBiz == null) return;

    for (final cat in _categoryOptions.keys) {
      final customRows = await AppDatabase.instance.getCustomOptions(activeBiz.id, cat);
      if (customRows.isNotEmpty && mounted) {
        setState(() {
          for (final row in customRows) {
            final val = row['value_ur'] as String;
            if (!_categoryOptions[cat]!.contains(val)) {
              _categoryOptions[cat]!.add(val);
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _garmentTabController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    _extraNotesController.dispose();
    super.dispose();
  }

  void _addCustomOptionForCategory(String categoryKey, String categoryName) async {
    final newOption = await showDialog<String>(
      context: context,
      builder: (_) => CustomOptionDialog(
        category: categoryKey,
        categoryName: categoryName,
      ),
    );

    if (newOption != null && newOption.isNotEmpty && mounted) {
      setState(() {
        if (!_categoryOptions[categoryKey]!.contains(newOption)) {
          _categoryOptions[categoryKey]!.add(newOption);
        }
        _selectedStyles[categoryKey] = newOption;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('نیا آپشن شامل ہو گیا: $newOption')),
      );
    }
  }

  void _copyLastMeasurement() {
    // Mock last measurements prefill for demonstration
    final sample = {
      'length': '40½',
      'chest': '38¼',
      'waist': '36',
      'hip': '40',
      'shoulder_teera': '17½',
      'sleeve_arm': '23¾',
      'collar_neck': '15½',
      'ghera': '22',
      'shalwar_length': '38',
      'paincha': '8½',
      'asan': '16',
      'thigh_ran': '28',
    };

    setState(() {
      sample.forEach((k, v) {
        if (_controllers.containsKey(k)) {
          _controllers[k]!.text = v;
        }
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('پچھلی ناپ کاپی ہو گئی')),
    );
  }

  Future<void> _saveMeasurement() async {
    setState(() => _isSaving = true);
    final activeBiz = ref.read(businessProvider).activeBusiness;
    if (activeBiz == null) return;

    try {
      final Map<String, dynamic> measurements = {};
      _controllers.forEach((k, c) {
        if (c.text.trim().isNotEmpty) {
          measurements[k] = c.text.trim();
        }
      });

      final model = MeasurementModel(
        id: _uuid.v4(),
        customerId: widget.customer.id,
        businessId: activeBiz.id,
        garmentTemplateId: _garmentTypes[_garmentTabController.index]['key']!,
        unit: _currentUnit,
        measurements: measurements,
        styleOptions: _selectedStyles,
        extraDetailsText: _extraNotesController.text.trim(),
        sketchSvgPath: _sketchPath,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      final db = await AppDatabase.instance.database;
      await db.insert('customer_measurements', model.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ناپ کامیابی سے محفوظ ہو گئی')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خرابی: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;
    final activeController = _controllers[_activeFieldKey] ?? _controllers.values.first;

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${AppStrings.get('measurement_register', lang)} - ${widget.customer.name}'),
          actions: [
            // Unit Switcher Toggle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'inch', label: Text('انچ')),
                  ButtonSegment(value: 'cm', label: Text('cm')),
                ],
                selected: {_currentUnit},
                onSelectionChanged: (val) => setState(() => _currentUnit = val.first),
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _garmentTabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: _garmentTypes.map((g) => Tab(text: g['ur'])).toList(),
          ),
        ),
        body: Column(
          children: [
            // Quick Action Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: const Color(0xFFF1F5F9),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(0, 36),
                    ),
                    icon: const Icon(Icons.history, size: 16),
                    label: Text(AppStrings.get('copy_last_measurement', lang), style: const TextStyle(fontSize: 12)),
                    onPressed: _copyLastMeasurement,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.draw, color: Color(0xFF1E3A8A)),
                    tooltip: AppStrings.get('body_sketch', lang),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SketchCanvasScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic, color: Color(0xFFDC2626)),
                    tooltip: AppStrings.get('voice_note', lang),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('صوتی نوٹ ریکارڈنگ جلد شامل ہوگی')),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Measurement Scrollable Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Measurement Grid Inputs
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _kameezFields.map((field) {
                        final key = field['key']!;
                        final label = field['ur']!;
                        final isFocused = _activeFieldKey == key;
                        final controller = _controllers[key]!;

                        return InkWell(
                          onTap: () => setState(() => _activeFieldKey = key),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 105,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isFocused ? const Color(0xFFEFF6FF) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isFocused ? const Color(0xFF1E3A8A) : const Color(0xFFE2E8F0),
                                width: isFocused ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                                    color: isFocused ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.text.isEmpty ? '—' : controller.text,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isFocused ? const Color(0xFF1E3A8A) : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Divider(height: 28),

                    // Style Options Section with (+) Add Custom Buttons
                    Text(
                      AppStrings.get('style_options', lang),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                    ),
                    const SizedBox(height: 10),

                    // 1. Collar / Ban
                    _buildStyleCategory(
                      categoryKey: 'collar_band',
                      categoryTitle: 'کالر / بین',
                      options: _categoryOptions['collar_band']!,
                    ),

                    // 2. Front Patti
                    _buildStyleCategory(
                      categoryKey: 'front_patti',
                      categoryTitle: 'سامنے پٹی (فرنٹ)',
                      options: _categoryOptions['front_patti']!,
                    ),

                    // 3. Cuff Style
                    _buildStyleCategory(
                      categoryKey: 'cuff_style',
                      categoryTitle: 'کف کا ڈیزائن',
                      options: _categoryOptions['cuff_style']!,
                    ),

                    // 4. Front Pocket
                    _buildStyleCategory(
                      categoryKey: 'pocket_style',
                      categoryTitle: 'سامنے جیب',
                      options: _categoryOptions['pocket_style']!,
                    ),

                    // 5. Side Pocket
                    _buildStyleCategory(
                      categoryKey: 'side_pocket',
                      categoryTitle: 'سائیڈ جیب',
                      options: _categoryOptions['side_pocket']!,
                    ),

                    // 6. Daman Style
                    _buildStyleCategory(
                      categoryKey: 'daman_style',
                      categoryTitle: 'دامن کا انداز',
                      options: _categoryOptions['daman_style']!,
                    ),

                    const Divider(height: 28),

                    // Extra Details & Instructions
                    Text(
                      AppStrings.get('extra_details', lang),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _extraNotesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'مثلاً: آستین میں ڈبل سلائی، پلیٹ گہری دیں، لوز فٹنگ...',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: Text(
                        AppStrings.get('save', lang),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      onPressed: _isSaving ? null : _saveMeasurement,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Persistent Tailor Fractional Keypad at bottom
            FractionalKeypad(
              controller: activeController,
              unit: _currentUnit,
              onNext: () {
                // Advance to next measurement field
                final keys = _kameezFields.map((f) => f['key']!).toList();
                final curIdx = keys.indexOf(_activeFieldKey);
                if (curIdx != -1 && curIdx < keys.length - 1) {
                  setState(() => _activeFieldKey = keys[curIdx + 1]);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleCategory({
    required String categoryKey,
    required String categoryTitle,
    required List<String> options,
  }) {
    final selectedVal = _selectedStyles[categoryKey];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
              ),
              // User-requested (+) Custom Option Button!
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('نیا آپشن (+)', style: TextStyle(fontSize: 12)),
                onPressed: () => _addCustomOptionForCategory(categoryKey, categoryTitle),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: options.map((opt) {
              final isSelected = selectedVal == opt;
              return ChoiceChip(
                label: Text(opt, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                selectedColor: const Color(0xFF1E3A8A),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStyles[categoryKey] = opt;
                    } else {
                      _selectedStyles.remove(categoryKey);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

