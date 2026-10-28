import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/localization/app_strings.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/onboarding/presentation/screens/onboarding_screen.dart';

class BusinessSwitcherScreen extends ConsumerStatefulWidget {
  const BusinessSwitcherScreen({super.key});

  @override
  ConsumerState<BusinessSwitcherScreen> createState() => _BusinessSwitcherScreenState();
}

class _BusinessSwitcherScreenState extends ConsumerState<BusinessSwitcherScreen> {
  void _switchBusiness(dynamic biz) {
    if (biz.pinHash != null && biz.pinHash!.isNotEmpty) {
      _showPinDialog(biz);
    } else {
      ref.read(businessProvider.notifier).setActiveBusiness(biz);
      Navigator.of(context).pop();
    }
  }

  void _showPinDialog(dynamic biz) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final lang = ref.watch(localeProvider).locale.languageCode;
        return AlertDialog(
          title: Text(AppStrings.get('pin_required', lang)),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppStrings.get('pin_code', lang),
              prefixIcon: const Icon(Icons.lock),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppStrings.get('cancel', lang)),
            ),
            ElevatedButton(
              onPressed: () {
                if (pinController.text == biz.pinHash) {
                  Navigator.of(ctx).pop();
                  ref.read(businessProvider.notifier).setActiveBusiness(biz);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('غلط پن کوڈ (Incorrect PIN)')),
                  );
                }
              },
              child: Text(AppStrings.get('confirm', lang)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bizState = ref.watch(businessProvider);
    final localeState = ref.watch(localeProvider);
    final lang = localeState.locale.languageCode;

    return Directionality(
      textDirection: localeState.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('switch_business', lang)),
        ),
        body: bizState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: bizState.businesses.length,
                itemBuilder: (context, index) {
                  final biz = bizState.businesses[index];
                  final isActive = biz.id == bizState.activeBusiness?.id;

                  return Card(
                    color: isActive ? const Color(0xFFEFF6FF) : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isActive ? const Color(0xFF1E3A8A) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: isActive ? const Color(0xFF1E3A8A) : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        child: Text(
                          biz.name.isNotEmpty ? biz.name.substring(0, 1) : 'B',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        biz.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isActive ? const Color(0xFF1E3A8A) : null,
                        ),
                      ),
                      subtitle: Text('${biz.ownerName} • ${biz.phonePrimary}'),
                      trailing: isActive
                          ? const Icon(Icons.check_circle, color: Color(0xFF1E3A8A), size: 28)
                          : biz.pinHash != null && biz.pinHash!.isNotEmpty
                              ? const Icon(Icons.lock_outline, color: Colors.grey)
                              : null,
                      onTap: () => _switchBusiness(biz),
                    ),
                  );
                },
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_business),
            label: Text(AppStrings.get('create_new_business', lang)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            },
          ),
        ),
      ),
    );
  }
}

