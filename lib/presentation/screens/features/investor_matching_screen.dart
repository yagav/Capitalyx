import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startup_application/core/theme/app_theme.dart';
import 'package:startup_application/presentation/controllers/feature_controller.dart';
import 'package:startup_application/presentation/providers/auth_provider.dart';
import 'package:startup_application/presentation/widgets/language_selector.dart';

class InvestorMatchingScreen extends ConsumerStatefulWidget {
  const InvestorMatchingScreen({super.key});

  @override
  ConsumerState<InvestorMatchingScreen> createState() =>
      _InvestorMatchingScreenState();
}

class _InvestorMatchingScreenState
    extends ConsumerState<InvestorMatchingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _subSectorController = TextEditingController();
  final _locationController = TextEditingController();
  final _fundingAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Dropdown values
  String? _selectedSector;
  String?
      _selectedStage; // Changed Name from Age to Stage to match schema 'startup_stage'
  String? _selectedBusinessModel;

  final List<String> _sectors = [
    'AgriTech',
    'FinTech',
    'HealthTech',
    'EdTech',
    'Other'
  ];
  final List<String> _stages = ['Pre-seed', 'Seed', 'Series A'];
  final List<String> _businessModels = ['B2B', 'B2C', 'SaaS'];

  @override
  void dispose() {
    _nameController.dispose();
    _subSectorController.dispose();
    _locationController.dispose();
    _fundingAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'startup_name': _nameController.text,
        'sector': _selectedSector,
        'sub_sector': _subSectorController.text,
        'age_stage': _selectedStage, // Controller maps this to 'startup_stage'
        'location': _locationController.text,
        'funding_amount': _fundingAmountController.text,
        'business_model': _selectedBusinessModel,
        'description': _descriptionController.text,
      };

      await ref.read(featureControllerProvider).submitInvestorMatching(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data saved successfully!')),
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

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Investor Matching',
            style: TextStyle(color: Colors.white)),
        actions: const [
          LanguageSelector(),
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: secondaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                        'Startup Name', _nameController, secondaryColor),
                    const SizedBox(height: 16),
                    _buildDropdown(
                        'Sector',
                        _sectors,
                        (v) => setState(() => _selectedSector = v),
                        secondaryColor,
                        _selectedSector),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Sub-sector', _subSectorController, secondaryColor),
                    const SizedBox(height: 16),
                    _buildDropdown(
                        'Startup Stage',
                        _stages,
                        (v) => setState(() => _selectedStage = v),
                        secondaryColor,
                        _selectedStage),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Location', _locationController, secondaryColor),
                    const SizedBox(height: 16),
                    _buildTextField('Funding Amount Sought',
                        _fundingAmountController, secondaryColor,
                        type: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildDropdown(
                        'Business Model',
                        _businessModels,
                        (v) => setState(() => _selectedBusinessModel = v),
                        secondaryColor,
                        _selectedBusinessModel),
                    const SizedBox(height: 16),
                    _buildTextField('Brief Description (Optional)',
                        _descriptionController, secondaryColor,
                        type: TextInputType.multiline,
                        lines: 4,
                        isOptional: true),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _submit,
                        child: const Text('Find Matches',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    Color color, {
    TextInputType type = TextInputType.text,
    int lines = 1,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: lines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
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
      ),
      validator: (value) {
        if (isOptional) return null;
        return value?.isEmpty ?? true ? 'Required' : null;
      },
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    Function(String?) onChanged,
    Color color,
    String? value,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
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
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Required' : null,
    );
  }
}
