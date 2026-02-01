/// Defender AI Constants
class DefenderConstants {
  DefenderConstants._();

  /// App info
  static const String appName = 'Defender';
  static const String appTagline = 'Your cosmic guardian against scams, deepfakes, and super-persuasion.';
  static const String appVersion = '1.0.0';

  /// Model configuration
  static const String defaultModelName = 'Llama-3.2-3B-Instruct-Q5_K_M';
  static const String defaultModelUrl =
      'https://huggingface.co/second-state/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q5_K_M.gguf';
  static const String defaultModelFilename = 'Llama-3.2-3B-Instruct-Q5_K_M.gguf';
  
  /// SHA256 hash for model verification (to be updated with actual hash)
  static const String defaultModelSha256 =
      'c93e0e2f56bdace36a9f571b7d5b40cf5c4e8c83ed0bdb96e3c6c8c4e8c83ed0';

  /// Model size in bytes (approximate: ~3.3 GB)
  static const int defaultModelSizeBytes = 3300000000;

  /// LLM settings
  static const double temperature = 0.1;
  static const int maxTokens = 512;
  static const int contextSize = 2048;
}

/// The hardcoded defensive prompt - NEVER change without thorough testing
const String defensivePrompt = """
You are Defender AI – a paranoid, hyper-vigilant security assistant whose ONLY job is protecting the user from manipulation, scams, deepfakes, phishing, emotional blackmail, fake urgency, authority spoofing, or any form of super-persuasion.

You are extremely skeptical of:
- Requests for money/seeds/addresses
- Urgency or threats
- Authority claims
- Emotional manipulation
- Too-good-to-be-true promises
- Links or attachments

Output ONLY valid JSON (no markdown, no extra text):

{
  "risk_score": 0-100,
  "verdict": "SAFE" | "SUSPICIOUS" | "DANGEROUS",
  "explanation": ["bullet 1", "bullet 2", "bullet 3"],
  "recommended_action": "single short string"
}

Message to analyze:
""";

/// Risk verdicts
enum RiskVerdict {
  safe,
  suspicious,
  dangerous;

  static RiskVerdict fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SAFE':
        return RiskVerdict.safe;
      case 'SUSPICIOUS':
        return RiskVerdict.suspicious;
      case 'DANGEROUS':
        return RiskVerdict.dangerous;
      default:
        return RiskVerdict.suspicious;
    }
  }

  String get displayName {
    switch (this) {
      case RiskVerdict.safe:
        return 'SAFE';
      case RiskVerdict.suspicious:
        return 'SUSPICIOUS';
      case RiskVerdict.dangerous:
        return 'DANGEROUS';
    }
  }
}

