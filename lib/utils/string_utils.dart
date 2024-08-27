
class StringUtils {

  static bool isBlank(String? text) {
    return text == null || text == "";
  }

  static bool isNotBlank(String? text) {
    return !isBlank(text);
  }

}