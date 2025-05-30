class UserValidator {
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) return '이름을 입력해 주세요';
    if (name.trim().length < 2) return '1글자 이상 입력해 주세요';
    return null;
  }
}