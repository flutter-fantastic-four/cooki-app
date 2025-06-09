import '../../domain/entity/validation_result.dart';

class ValidationDto {
  final bool isValid;

  const ValidationDto({required this.isValid});

  factory ValidationDto.fromJson(Map<String, dynamic> json) {
    return ValidationDto(
      isValid: json['isValid'] as bool,
    );
  }

  ValidationResult toEntity() {
    return ValidationResult(isValid: isValid);
  }
}