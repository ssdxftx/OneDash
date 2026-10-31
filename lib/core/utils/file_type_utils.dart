import '../../data/dto/file/file_item_dto.dart';

class FileTypeUtils {
  FileTypeUtils._();

  static const _imageExts = {
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
    '.svg',
    '.ico',
  };

  static const _textExts = {
    '.txt',
    '.md',
    '.log',
    '.conf',
    '.ini',
    '.sh',
    '.py',
    '.js',
    '.json',
    '.yaml',
    '.yml',
    '.html',
    '.css',
    '.php',
    '.go',
    '.sql',
  };

  static const _textFileNames = {'dockerfile', 'makefile', 'authorized_keys'};

  static const _archiveExts = {
    '.zip',
    '.gz',
    '.bz2',
    '.tar.bz2',
    '.tar',
    '.tgz',
    '.tar.gz',
    '.xz',
    '.tar.xz',
    '.rar',
    '.7z',
  };

  /// 是否为图片
  static bool isImage(FileItemDto item) {
    if (item.isDir) return false;
    return _imageExts.contains(item.extension.toLowerCase());
  }

  /// 是否为 SVG 矢量图
  static bool isSvg(FileItemDto item) {
    if (item.isDir) return false;
    return isSvgByName(item.name);
  }

  /// 通过文件名判断是否为 SVG
  static bool isSvgByName(String name) {
    return name.toLowerCase().endsWith('.svg');
  }

  /// 是否为可编辑文本
  static bool isEditable(FileItemDto item) {
    if (item.isDir) return false;
    final ext = item.extension.toLowerCase();
    if (_textExts.contains(ext)) return true;
    // 以点开头的配置文件 (如 .env, .gitignore)
    if (item.name.startsWith('.')) return true;
    // 无扩展名的已知文本文件
    return _textFileNames.contains(item.name.toLowerCase());
  }

  /// 是否为压缩包
  static bool isArchive(FileItemDto item) {
    if (item.isDir) return false;
    final ext = item.extension.toLowerCase();
    if (_archiveExts.contains(ext)) return true;

    // 处理多重后缀如 .tar.gz
    final name = item.name.toLowerCase();
    return _archiveExts.any(name.endsWith);
  }
}
