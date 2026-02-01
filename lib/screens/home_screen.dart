import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../services/model_service.dart';
import '../services/llm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ModelService _modelService = ModelService();
  final LlmService _llmService = LlmService();

  bool _isModelDownloaded = false;
  bool _isModelLoaded = false;
  bool _isDownloading = false;
  bool _isLoadingModel = false;
  double _downloadProgress = 0;
  String? _error;

  bool _isAnalyzing = false;
  AnalysisResult? _result;

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
    _messageController.addListener(() => setState(() {}));
  }

  Future<void> _checkModelStatus() async {
    final downloaded = await _modelService.isModelDownloaded();
    setState(() => _isModelDownloaded = downloaded);
    // Don't auto-load - let user trigger it to avoid simulator crashes
  }

  Future<void> _loadLlm() async {
    setState(() => _isLoadingModel = true);
    try {
      final success = await _llmService.loadModel();
      setState(() {
        _isModelLoaded = success;
        _isLoadingModel = false;
        if (!success) _error = 'Failed to load AI model';
      });
    } catch (e) {
      setState(() {
        _isLoadingModel = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _error = null;
    });

    await _modelService.downloadModel(
      onProgress: (progress) {
        setState(() => _downloadProgress = progress);
      },
      onComplete: () {
        setState(() {
          _isDownloading = false;
          _isModelDownloaded = true;
        });
        _loadLlm(); // Auto-load after download
      },
      onError: (error) {
        setState(() {
          _isDownloading = false;
          _error = error;
        });
      },
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _messageController.text = data!.text!;
      setState(() {});
    }
  }

  Future<void> _analyzeMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (!_isModelLoaded) {
      setState(() => _error = 'AI model not loaded yet');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _result = null;
      _error = null;
    });

    try {
      final result = await _llmService.analyze(_messageController.text);
      setState(() {
        _isAnalyzing = false;
        _result = result;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _error = 'Analysis failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DefenderColors.backgroundLight,
              DefenderColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                if (!_isModelDownloaded || !_isModelLoaded) ...[
                  _buildModelSection(),
                  const SizedBox(height: 24),
                ],
                if (_error != null) ...[
                  _buildErrorBanner(),
                  const SizedBox(height: 16),
                ],
                _buildInputSection(),
                const SizedBox(height: 16),
                _buildCheckButton(),
                if (_result != null) ...[
                  const SizedBox(height: 24),
                  _buildResultSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.shield_outlined,
          size: 64,
          color: DefenderColors.primary,
        ).animate().fadeIn().scale(),
        const SizedBox(height: 12),
        Text(
          'DEFENDER',
          style: DefenderTextStyles.displayMedium.copyWith(
            letterSpacing: 4,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 4),
        Text(
          'AI-powered scam & manipulation detector',
          style: DefenderTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DefenderColors.dangerous.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DefenderColors.dangerous.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: DefenderColors.dangerous, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: DefenderTextStyles.caption.copyWith(color: DefenderColors.dangerous),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _error = null),
            color: DefenderColors.dangerous,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSection() {
    // Loading in progress
    if (_isLoadingModel) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DefenderColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DefenderColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 12),
            Text('Loading AI Model...', style: DefenderTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              'This may take 30-60 seconds.',
              style: DefenderTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    // Downloaded but not loaded - show load button
    if (_isModelDownloaded && !_isModelLoaded) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DefenderColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DefenderColors.safe.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 40,
              color: DefenderColors.safe,
            ),
            const SizedBox(height: 12),
            Text('Model Downloaded', style: DefenderTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Tap below to load the AI into memory.',
              style: DefenderTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadLlm,
              icon: const Icon(Icons.memory),
              label: const Text('Load AI Model'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DefenderColors.safe,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 600.ms);
    }

    // Need to download
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DefenderColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DefenderColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.download_rounded,
            size: 40,
            color: DefenderColors.primaryLight,
          ),
          const SizedBox(height: 12),
          Text(
            'AI Model Required',
            style: DefenderTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Download the 2.3GB AI model to enable offline analysis.',
            style: DefenderTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_isDownloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _downloadProgress,
                minHeight: 8,
                backgroundColor: DefenderColors.surfaceLight,
                valueColor: const AlwaysStoppedAnimation(DefenderColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_downloadProgress * 100).toStringAsFixed(1)}%',
              style: DefenderTextStyles.caption,
            ),
          ] else ...[
            _buildDownloadButton(),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildDownloadButton() {
    return ElevatedButton.icon(
      onPressed: _startDownload,
      icon: const Icon(Icons.download),
      label: const Text('Download Model'),
      style: ElevatedButton.styleFrom(
        backgroundColor: DefenderColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: DefenderColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DefenderColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _messageController,
            maxLines: 6,
            style: DefenderTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Paste a suspicious message, link, or crypto address...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: DefenderTextStyles.bodyMedium.copyWith(
                color: DefenderColors.textMuted,
              ),
            ),
          ),
          const Divider(height: 1, color: DefenderColors.surfaceLight),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.paste, size: 18),
                  label: const Text('Paste'),
                  style: TextButton.styleFrom(
                    foregroundColor: DefenderColors.textSecondary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    _messageController.clear();
                    setState(() => _result = null);
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: DefenderColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildCheckButton() {
    final canCheck = _messageController.text.trim().isNotEmpty && !_isAnalyzing && _isModelLoaded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: canCheck
            ? [
                BoxShadow(
                  color: DefenderColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: canCheck ? _analyzeMessage : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: DefenderColors.primary,
          disabledBackgroundColor: DefenderColors.surfaceLight,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isAnalyzing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(DefenderColors.textPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'CHECK MESSAGE',
                    style: DefenderTextStyles.labelLarge,
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 1000.ms);
  }

  Widget _buildResultSection() {
    final result = _result!;
    final color = _getVerdictColor(result.verdict);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DefenderColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.verdict,
                  style: DefenderTextStyles.labelLarge.copyWith(color: color),
                ),
              ),
              const Spacer(),
              Text(
                'Risk: ${result.riskScore}%',
                style: DefenderTextStyles.titleMedium.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: result.riskScore / 100,
              minHeight: 6,
              backgroundColor: DefenderColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 16),
          ...result.explanation.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, size: 18, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(point, style: DefenderTextStyles.bodyMedium),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DefenderColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.recommendedAction,
                    style: DefenderTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Color _getVerdictColor(String verdict) {
    switch (verdict.toUpperCase()) {
      case 'SAFE':
        return DefenderColors.safe;
      case 'SUSPICIOUS':
        return DefenderColors.suspicious;
      case 'DANGEROUS':
        return DefenderColors.dangerous;
      default:
        return DefenderColors.suspicious;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}


