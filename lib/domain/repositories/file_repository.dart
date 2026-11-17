import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../data/dto/file/file_log_dto.dart';

import '../../data/dto/file/file_convert_dto.dart';
import '../../data/dto/file/file_item_dto.dart';
import '../../data/dto/file/user_group_dto.dart';
import '../../data/dto/file/file_share_dto.dart';
import '../../data/dto/common/page_result.dart';
import '../../data/dto/file/file_ai_search_dto.dart';
import '../../data/dto/file/file_favorite_dto.dart';
import '../../data/dto/file/file_tree_dto.dart';

/// 文件管理仓库接口。
abstract class FileRepository {
  /// 搜索指定路径下的文件列表。
  Future<FileItemDto> searchFiles({
    required String path,
    bool expand = true,
    bool showHidden = true,
    int page = 1,
    int pageSize = 100,
    String search = '',
    bool containSub = false,
    String sortBy = 'name',
    String? sortOrder,
  });

  /// 文件内容搜索，可选 AI 摘要。
  Future<FileAiSearchResultDto> aiSearch({
    required String path,
    required String query,
    bool containSub,
    bool matchCase,
    bool wholeWord,
    bool useRegex,
    int maxItems,
  });

  /// 获取文件内容。
  Future<FileItemDto> getFileContent({
    required String path,
    bool isDetail = false,
  });

  /// 保存文件内容。
  Future<void> saveFileContent({required String path, required String content});

  /// 流式下载文件到指定本地路径。
  Future<void> downloadFileTo({
    required String path,
    required String savePath,
    void Function(int received, int total)? onReceiveProgress,
    CancelToken? cancelToken,
  });

  /// 下载文件内容为字节数组。
  Future<Uint8List> downloadBytes(String path);

  /// 获取文件/目录大小。
  Future<int> getFileSize(String path);
  Future<FileLogDto> readRuntimeLog({
    required int id,
    required String type,
    String name,
    int page,
    int pageSize,
    bool latest,
  });

  /// 获取回收站状态。
  Future<bool> getRecycleStatus();

  /// 删除文件/目录。
  Future<void> deleteFile({
    required String path,
    required bool isDir,
    bool forceDelete = false,
  });

  /// 获取网站根目录。
  Future<String> getWebsiteRootDir();

  /// 添加收藏。
  Future<int> favoriteFile(String path);

  /// 移除收藏。
  Future<void> deleteFavorite(int favoriteID);

  /// 查询收藏列表。
  Future<List<FileFavoriteDto>> searchFavorites();

  /// 获取用户和用户组。
  Future<UserGroupDto> getUserGroups();

  /// 更新文件/目录权限。
  Future<void> updatePermissions({
    required List<String> paths,
    required int mode,
    required String user,
    required String group,
    bool sub = true,
  });

  Future<String> wget({
    required String url,
    required String path,
    required String name,
    bool ignoreCertificate = false,
  });

  Future<void> wgetStop(String key);

  Future<List<String>> removeWgetRecords(List<String> keys);

  Future<List<String>> wgetProcessKeys();

  /// 连接远程下载进度 WebSocket。
  Future<WebSocketChannel> connectWgetProcessWebSocket();

  /// 查询上传目录记录。
  Future<PageResult<FileUploadDto>> searchUploadFiles({
    required String path,
    int page,
    int pageSize,
  });

  /// 提交文件格式转换任务。
  Future<void> convertFiles({
    required List<Map<String, dynamic>> files,
    required String outputPath,
    bool deleteSource,
    String taskID,
  });

  /// 查询文件转换日志。
  Future<PageResult<FileConvertLogDto>> convertLogs({int page, int pageSize});

  /// 分块下载文件内容。
  Future<Uint8List> chunkDownload({required String path, required String name});

  /// 等待 1Panel 后台任务结束。
  Future<void> waitTask(String taskID, {String subject = 'File task'});

  /// 压缩文件。
  Future<void> compressFiles({
    required List<String> files,
    required String type,
    required String dst,
    required String name,
    bool replace = false,
    String? secret,
    String taskID = '',
  });

  /// 停止压缩任务。
  Future<void> stopCompress(String taskID);

  /// 解压文件。
  Future<void> decompressFile({
    required String path,
    required String type,
    required String dst,
    String? secret,
    String taskID = '',
  });

  /// 停止解压任务。
  Future<void> stopDecompress(String taskID);

  /// 检查文件/目录是否存在。
  Future<bool> checkFileExists(String path);

  /// 批量检查文件/目录是否存在。
  Future<List<FileItemDto>> batchCheckFilesExists(List<String> paths);

  /// 移动或复制文件/目录。
  Future<void> moveCopyFiles({
    required List<String> oldPaths,
    required String newPath,
    required String type, // 'copy' 或 'cut'
    String name = '',
    bool cover = false,
    List<String> coverPaths = const [],
    String taskID = '',
  });

  /// 停止移动/复制任务。
  Future<void> stopMove(String taskID);

  /// 上传单个文件，内部自动按大小选择普通上传或分片上传。
  Future<void> uploadFile({
    required String filePath,
    required String targetPath,
    bool overwrite = true,
    void Function(double progress)? onProgress,
    void Function(int uploadedBytes)? onChunkUploaded,
    String? uploadId,
    int startOffset = 0,
    CancelToken? cancelToken,
  });

  Future<void> stopChunkUpload(String uploadId);

  /// 创建文件或目录。
  Future<void> createFileOrDir({
    required String path,
    required bool isDir,
    int? mode,
    String? linkPath,
    bool isLink = false,
    bool isSymlink = true,
    String content = '',
    bool sub = false,
  });

  /// 创建或更新文件分享。
  Future<FileShareDto> createFileShare({
    required String path,
    required int expireMinutes,
    String? password,
  });

  /// 取消文件分享。
  Future<void> deleteFileShare(String path);

  /// 重命名文件或目录。
  Future<void> renameFile({required String oldPath, required String newPath});

  /// 修改文件/目录权限。
  Future<void> changeMode({required String path, required int mode, bool sub});

  /// 修改文件/目录所有者。
  Future<void> changeOwner({
    required String path,
    required String user,
    required String group,
    bool sub,
  });

  /// 批量删除文件/目录。
  Future<void> batchDeleteFiles({
    required List<String> paths,
    required bool isDir,
  });

  /// 计算目录体积。
  Future<int> getDepthSize(String path);

  /// 查询文件历史。
  Future<PageResult<Map<String, dynamic>>> searchHistory({
    required String path,
    String scope,
    int page,
    int pageSize,
  });

  /// 读取历史版本内容。
  Future<Map<String, dynamic>> getHistoryContent(int id);

  /// 回滚到历史版本。
  Future<Map<String, dynamic>> restoreHistory(int id);

  /// 删除历史版本。
  Future<void> deleteHistory(List<int> ids);

  /// 获取文件分享详情。
  Future<FileShareDto?> getFileShareDetail(String path);

  Future<Map<String, dynamic>> getPublicShareInfo(String code);
  Future<void> checkFileShare({required String code, String? password});
  Future<void> downloadSharedFile({
    required String code,
    required String savePath,
    String? password,
  });

  /// 分页查询分享列表。
  Future<Map<String, dynamic>> searchFileShares({
    int page = 1,
    int pageSize = 20,
  });

  /// 读取文件预览内容。
  Future<FileItemDto> previewFile(String path, {bool isDetail = false});

  /// 获取目录树。
  Future<List<FileTreeNodeDto>> getFileTree({
    required String path,
    bool containSub = false,
  });

  /// 批量获取文件备注。
  Future<Map<String, String>> getFileRemarks(List<String> paths);

  /// 设置文件备注。
  Future<void> setFileRemark({required String path, required String remark});

  /// 获取文件分享二维码。
  Future<List<int>> getFileShareQrCode(String code);

  /// 获取宿主机挂载点。
  Future<List<Map<String, dynamic>>> getHostMounts();

  /// 分页获取回收站列表。
  Future<Map<String, dynamic>> searchRecycleBin({
    int page = 1,
    int pageSize = 20,
  });

  /// 还原回收站项。
  Future<void> restoreRecycleItem({
    required String from,
    required String rName,
    String? name,
  });

  /// 清空回收站。
  Future<void> clearRecycleBin();

  /// 获取回收站开关状态。
  Future<String> getRecycleBinStatus();
}
