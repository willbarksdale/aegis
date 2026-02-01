import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

const String _modelUrl =
    'https://huggingface.co/second-state/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q5_K_M.gguf';
const String _modelFilename = 'Llama-3.2-3B-Instruct-Q5_K_M.gguf';

class ModelService {
  final Dio _dio = Dio();
  CancelToken? _cancelToken;

  Future<String> get modelPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_modelFilename';
  }

  Future<bool> isModelDownloaded() async {
    final path = await modelPath;
    return File(path).existsSync();
  }

  Future<void> downloadModel({
    required void Function(double progress) onProgress,
    required void Function() onComplete,
    required void Function(String error) onError,
  }) async {
    _cancelToken = CancelToken();
    final path = await modelPath;

    try {
      debugPrint('[ModelService] Starting download to: $path');
      await _dio.download(
        _modelUrl,
        path,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );
      debugPrint('[ModelService] Download complete!');
      onComplete();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        debugPrint('[ModelService] Download cancelled');
      } else {
        debugPrint('[ModelService] Download error: $e');
        onError(e.message ?? 'Download failed');
      }
    } catch (e) {
      debugPrint('[ModelService] Error: $e');
      onError(e.toString());
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
  }

  Future<void> deleteModel() async {
    final path = await modelPath;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

