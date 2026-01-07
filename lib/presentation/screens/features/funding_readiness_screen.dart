import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startup_application/core/theme/app_theme.dart';
import 'package:startup_application/presentation/controllers/feature_controller.dart';
import 'package:startup_application/presentation/providers/auth_provider.dart';
import 'package:startup_application/presentation/widgets/language_selector.dart';
import 'package:startup_application/presentation/widgets/translated_text.dart';
import 'package:startup_application/presentation/providers/language_provider.dart';

class FundingReadinessScreen extends ConsumerStatefulWidget {
  const FundingReadinessScreen({super.key});

  @override
  ConsumerState<FundingReadinessScreen> createState() =>
      _FundingReadinessScreenState();
}

class _FundingReadinessScreenState
    extends ConsumerState<FundingReadinessScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers
  final _foundersCountController = TextEditingController();
  final _founderExperienceController = TextEditingController();
  final _usersController = TextEditingController();
  final _revenueController = TextEditingController();
  final _targetCustomerController = TextEditingController();
  final _marketSizeController = TextEditingController();
  final _revenueModelController = TextEditingController();
  final _previousFundingController = TextEditingController();

  // UI state
  String _productStage = 'Idea';
  bool _hasPilots = false;
  String _growthRate = 'Low';
  bool _hasPartnerships = false;

  /// 🔑 UI → DB SAFE MAPPINGS
  final Map<String, String> _growthRateMap = {
    'Low': 'low',
    'Medium': 'medium',
    'High': 'high',
  };

  @override
  void dispose() {
    _foundersCountController.dispose();
    _founderExperienceController.dispose();
    _usersController.dispose();
    _revenueController.dispose();
    _targetCustomerController.dispose();
    _marketSizeController.dispose();
    _revenueModelController.dispose();
    _previousFundingController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final data = {
        'founders_count': _foundersCountController.text,
        'founder_experience': _founderExperienceController.text,

        // ✅ normalized
        'product_stage': _productStage.toLowerCase(),

        'users': _usersController.text,
        'revenue': _revenueController.text,
        'has_pilots': _hasPilots,
        'target_customer': _targetCustomerController.text,
        'market_size': _marketSizeController.text,
        'revenue_model': _revenueModelController.text,

        // ✅ mapped
        'growth_rate': _growthRateMap[_growthRate],

        'partnerships_bool': _hasPartnerships,
        'previous_funding': _previousFundingController.text,
      };

      await ref.read(featureControllerProvider).submitFundingReadiness(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Readiness check submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final sector = authState.profile?.startupSector ?? 'Other';
    final secondaryColor = AppTheme.getSecondaryColorForSector(sector);
    final languageState = ref.watch(languageProvider);

    final theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.dark(primary: secondaryColor),
      canvasColor: const Color(0xFF121212),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const TranslatedText('Funding Readiness',
            style: TextStyle(color: Colors.white)),
        actions: const [
          LanguageSelector(),
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: secondaryColor))
          : Theme(
              data: theme,
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 2) {
                    setState(() => _currentStep += 1);
                  } else {
                    _submit();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep -= 1);
                  }
                },
                steps: [
                  Step(
                    title: const TranslatedText('Team',
                        style: TextStyle(color: Colors.white)),
                    content: Column(
                      children: [
                        _buildTextField(
                            'Number of Founders',
                            _foundersCountController,
                            secondaryColor,
                            TextInputType.number),
                        const SizedBox(height: 16),
                        _buildTextField(
                            'Founder Experience',
                            _founderExperienceController,
                            secondaryColor,
                            TextInputType.multiline,
                            3),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                  ),
                  Step(
                    title: const TranslatedText('Product & Market',
                        style: TextStyle(color: Colors.white)),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TranslatedText('Product Stage',
                            style: TextStyle(color: Colors.white70)),
                        Row(
                          children: ['Idea', 'MVP', 'Live']
                              .map((val) => Expanded(
                                    child: RadioListTile<String>(
                                      title: TranslatedText(val,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      value: val,
                                      groupValue: _productStage,
                                      activeColor: secondaryColor,
                                      onChanged: (v) =>
                                          setState(() => _productStage = v!),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField('Target Customer',
                            _targetCustomerController, secondaryColor),
                        const SizedBox(height: 16),
                        _buildTextField('Market Size', _marketSizeController,
                            secondaryColor),
                        const SizedBox(height: 16),
                        _buildTextField('Revenue Model',
                            _revenueModelController, secondaryColor),
                      ],
                    ),
                    isActive: _currentStep >= 1,
                  ),
                  Step(
                    title: const TranslatedText('Traction & Growth',
                        style: TextStyle(color: Colors.white)),
                    content: Column(
                      children: [
                        _buildTextField('Active Users', _usersController,
                            secondaryColor, TextInputType.number),
                        const SizedBox(height: 16),
                        _buildTextField(
                            'Monthly Revenue (₹)',
                            _revenueController,
                            secondaryColor,
                            TextInputType.number,
                            1,
                            true), // Optional
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const TranslatedText('Active pilots?',
                              style: TextStyle(color: Colors.white)),
                          value: _hasPilots,
                          activeColor: secondaryColor,
                          onChanged: (v) => setState(() => _hasPilots = v),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _growthRate,
                          decoration: _inputDecoration(
                              'Growth Rate', secondaryColor,
                              isOptional: true),
                          dropdownColor: const Color(0xFF1E1E1E),
                          style: const TextStyle(color: Colors.white),
                          items: _growthRateMap.keys
                              .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: TranslatedText(
                                      e))) // Translate items? Yes
                              .toList(),
                          onChanged: (v) => setState(() => _growthRate = v!),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField('Previous Funding',
                            _previousFundingController, secondaryColor),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const TranslatedText('Key Partnerships?',
                              style: TextStyle(color: Colors.white)),
                          value: _hasPartnerships,
                          activeColor: secondaryColor,
                          onChanged: (v) =>
                              setState(() => _hasPartnerships = v),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 2,
                  ),
                ],
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, Color color,
      {bool isOptional = false}) {
    final languageState = ref.watch(languageProvider);

    // Attempt translation
    final translatedLabel = languageState.translations[label] ?? label;
    String? hintText;

    if (isOptional) {
      hintText = languageState.translations['(Optional)'] ?? '(Optional)';
    }

    return InputDecoration(
      labelText: translatedLabel,
      hintText: hintText,
      floatingLabelBehavior: isOptional
          ? FloatingLabelBehavior.always
          : null, // Optional enhancement
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    Color color, [
    TextInputType type = TextInputType.text,
    int lines = 1,
    bool isOptional = false,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: lines,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, color, isOptional: isOptional),
    );
  }
}
