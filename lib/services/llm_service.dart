import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_llama/flutter_llama.dart';
import '../core/constants.dart';
import 'model_service.dart';

class LlmService {
  final FlutterLlama _llama = FlutterLlama.instance;
  final ModelService _modelService = ModelService();

  bool get isLoaded => _llama.isModelLoaded;

  Future<bool> loadModel() async {
    if (_llama.isModelLoaded) return true;

    final path = await _modelService.modelPath;
    debugPrint('[LlmService] Loading model from: $path');

    // Conservative settings for simulator compatibility
    // Real device can handle more aggressive settings
    final config = LlamaConfig(
      modelPath: path,
      nThreads: 2,           // Fewer threads for stability
      nGpuLayers: 0,         // CPU only - simulator doesn't handle Metal well
      contextSize: 1024,     // Smaller context to save memory
      batchSize: 256,        // Smaller batch
      useGpu: false,         // Disable GPU for simulator
      verbose: true,         // Enable logging for debugging
    );

    try {
      return await _llama.loadModel(config);
    } catch (e) {
      debugPrint('[LlmService] Failed to load model: $e');
      return false;
    }
  }

  Future<AnalysisResult> analyze(String message) async {
    if (!_llama.isModelLoaded) {
      throw StateError('Model not loaded');
    }

    final prompt = '$defensivePrompt"$message"';
    debugPrint('[LlmService] Analyzing message...');

    final params = GenerationParams(
      prompt: prompt,
      temperature: DefenderConstants.temperature,
      maxTokens: DefenderConstants.maxTokens,
      topP: 0.9,
      topK: 40,
      repeatPenalty: 1.1,
      stopSequences: ['```', '\n\n\n'],
    );

    try {
      final response = await _llama.generate(params);
      debugPrint('[LlmService] Raw response: ${response.text}');
      return _parseResponse(response.text);
    } catch (e) {
      debugPrint('[LlmService] Generation error: $e');
      rethrow;
    }
  }

  AnalysisResult _parseResponse(String text) {
    try {
      // Find JSON in response
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      
      if (start == -1 || end == -1 || end <= start) {
        throw FormatException('No JSON found in response');
      }

      final jsonStr = text.substring(start, end + 1);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      return AnalysisResult(
        riskScore: (json['risk_score'] as num).toInt(),
        verdict: json['verdict'] as String,
        explanation: List<String>.from(json['explanation'] ?? []),
        recommendedAction: json['recommended_action'] as String? ?? 'Review carefully',
      );
    } catch (e) {
      debugPrint('[LlmService] Parse error: $e');
      // Fallback - try to extract what we can
      return AnalysisResult(
        riskScore: 50,
        verdict: 'SUSPICIOUS',
        explanation: ['Unable to fully parse AI response', 'Manual review recommended'],
        recommendedAction: 'Exercise caution with this message',
      );
    }
  }

  Future<void> unload() async {
    await _llama.unloadModel();
  }
}

class AnalysisResult {
  final int riskScore;
  final String verdict;
  final List<String> explanation;
  final String recommendedAction;

  AnalysisResult({
    required this.riskScore,
    required this.verdict,
    required this.explanation,
    required this.recommendedAction,
  });
}

