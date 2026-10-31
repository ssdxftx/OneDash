class FileIconPathCache {
  const FileIconPathCache._();

  static String? websitePath;
  static String? onePanelPath;

  static void updatePaths(String path) {
    if (path.isEmpty) return;
    websitePath = path;

    final lastIndex = path.lastIndexOf('/');
    if (lastIndex > 0) {
      onePanelPath = path.substring(0, lastIndex);
    }
  }
}
