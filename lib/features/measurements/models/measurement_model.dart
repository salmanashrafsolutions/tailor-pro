import 'dart:convert';

class MeasurementModel {
  final String id;
  final String customerId;
  final String businessId;
  final String garmentTemplateId;
  final int versionNumber;
  final String unit; // 'inch' or 'cm'
  final Map<String, dynamic> measurements;
  final Map<String, dynamic> styleOptions;
  final String? extraDetailsText;
  final String? audioNotePath;
  final String? sketchSvgPath;
  final String? recordedByStaffId;
  final int createdAt;

  MeasurementModel({
    required this.id,
    required this.customerId,
    required this.businessId,
    required this.garmentTemplateId,
    this.versionNumber = 1,
    this.unit = 'inch',
    required this.measurements,
    this.styleOptions = const {},
    this.extraDetailsText,
    this.audioNotePath,
    this.sketchSvgPath,
    this.recordedByStaffId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'business_id': businessId,
      'garment_template_id': garmentTemplateId,
      'version_number': versionNumber,
      'unit': unit,
      'measurements_json': jsonEncode(measurements),
      'style_options_json': jsonEncode(styleOptions),
      'extra_details_text': extraDetailsText,
      'audio_note_path': audioNotePath,
      'sketch_svg_path': sketchSvgPath,
      'recorded_by_staff_id': recordedByStaffId,
      'created_at': createdAt,
    };
  }

  factory MeasurementModel.fromMap(Map<String, dynamic> map) {
    return MeasurementModel(
      id: map['id'],
      customerId: map['customer_id'],
      businessId: map['business_id'],
      garmentTemplateId: map['garment_template_id'],
      versionNumber: map['version_number'] ?? 1,
      unit: map['unit'] ?? 'inch',
      measurements: map['measurements_json'] != null
          ? jsonDecode(map['measurements_json']) as Map<String, dynamic>
          : {},
      styleOptions: map['style_options_json'] != null
          ? jsonDecode(map['style_options_json']) as Map<String, dynamic>
          : {},
      extraDetailsText: map['extra_details_text'],
      audioNotePath: map['audio_note_path'],
      sketchSvgPath: map['sketch_svg_path'],
      recordedByStaffId: map['recorded_by_staff_id'],
      createdAt: map['created_at'],
    );
  }
}

