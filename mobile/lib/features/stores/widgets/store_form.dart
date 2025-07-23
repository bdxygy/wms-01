import 'package:flutter/material.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/models/store.dart';
import '../../../core/models/api_requests.dart';
import '../../../core/services/store_service.dart';
import '../../../core/widgets/loading.dart';

class StoreForm extends StatefulWidget {
  final Store? store; // null for create, Store instance for edit
  final VoidCallback? onSuccess;

  const StoreForm({
    super.key,
    this.store,
    this.onSuccess,
  });

  @override
  State<StoreForm> createState() => _StoreFormState();
}

class _StoreFormState extends State<StoreForm> {
  final _formKey = GlobalKey<FormState>();
  final StoreService _storeService = StoreService();

  // Form controllers
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _mapLocationController = TextEditingController();

  // Form state
  bool _isActive = true;
  bool _isLoading = false;
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;

  bool get _isEditMode => widget.store != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _timezoneController.dispose();
    _mapLocationController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (_isEditMode && widget.store != null) {
      final store = widget.store!;
      _nameController.text = store.name;
      _typeController.text = store.type;
      _addressLine1Controller.text = store.addressLine1;
      _addressLine2Controller.text = store.addressLine2 ?? '';
      _cityController.text = store.city;
      _provinceController.text = store.province;
      _postalCodeController.text = store.postalCode;
      _countryController.text = store.country;
      _phoneController.text = store.phoneNumber;
      _emailController.text = store.email ?? '';
      _timezoneController.text = store.timezone;
      _mapLocationController.text = store.mapLocation ?? '';
      _isActive = store.isActive;

      // Parse time if available
      if (store.openTime != null) {
        _openTime = TimeOfDay.fromDateTime(store.openTime!);
      }
      if (store.closeTime != null) {
        _closeTime = TimeOfDay.fromDateTime(store.closeTime!);
      }
    } else {
      // Set defaults for create mode
      _countryController.text = 'Indonesia';
      _timezoneController.text = 'Asia/Jakarta';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditMode) {
        await _updateStore();
      } else {
        await _createStore();
      }

      if (!mounted) return;
      
      // Show success message
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? l10n.storeUpdatedSuccessfully : l10n.storeCreatedSuccessfully,
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Call success callback
      widget.onSuccess?.call();

    } catch (e) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? l10n.failedToUpdateStore : l10n.failedToCreateStore,
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createStore() async {
    final request = CreateStoreRequest(
      name: _nameController.text.trim(),
      address: _buildFullAddress(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      description: null, // Could add description field if needed
    );

    await _storeService.createStore(request);
  }

  Future<void> _updateStore() async {
    final request = UpdateStoreRequest(
      name: _nameController.text.trim(),
      address: _buildFullAddress(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      description: null, // Could add description field if needed
    );

    await _storeService.updateStore(widget.store!.id, request);
  }

  String _buildFullAddress() {
    final parts = [
      _addressLine1Controller.text.trim(),
      if (_addressLine2Controller.text.trim().isNotEmpty) _addressLine2Controller.text.trim(),
      _cityController.text.trim(),
      _provinceController.text.trim(),
      _postalCodeController.text.trim(),
      _countryController.text.trim(),
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final l10n = AppLocalizations.of(context)!;
    final initialTime = isOpenTime ? _openTime : _closeTime;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: isOpenTime ? l10n.selectOpenTime : l10n.selectCloseTime,
    );

    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Information Section
            _buildSection(
              l10n.storeInformation,
              Icons.store,
              [
                _buildTextField(
                  controller: _nameController,
                  label: l10n.storeName,
                  hint: l10n.enterStoreName,
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _typeController,
                  label: l10n.storeType,
                  hint: l10n.enterStoreType,
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildStatusField(l10n, theme),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _timezoneController,
                  label: l10n.timezone,
                  hint: l10n.enterTimezone,
                  required: true,
                ),
              ],
              theme,
            ),

            const SizedBox(height: 24),

            // Operating Hours Section
            _buildSection(
              l10n.operatingHours,
              Icons.access_time,
              [
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeField(
                        label: l10n.openTime,
                        time: _openTime,
                        onTap: () => _selectTime(context, true),
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeField(
                        label: l10n.closeTime,
                        time: _closeTime,
                        onTap: () => _selectTime(context, false),
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ],
              theme,
            ),

            const SizedBox(height: 24),

            // Address Information Section
            _buildSection(
              l10n.addressInformation,
              Icons.location_on,
              [
                _buildTextField(
                  controller: _addressLine1Controller,
                  label: l10n.addressLine1,
                  hint: l10n.enterAddressLine1,
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressLine2Controller,
                  label: l10n.addressLine2,
                  hint: l10n.enterAddressLine2,
                  required: false,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: l10n.city,
                        hint: l10n.enterCity,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _provinceController,
                        label: l10n.province,
                        hint: l10n.enterProvince,
                        required: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _postalCodeController,
                        label: l10n.postalCode,
                        hint: l10n.enterPostalCode,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _countryController,
                        label: l10n.country,
                        hint: l10n.enterCountry,
                        required: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _mapLocationController,
                  label: l10n.mapLocation,
                  hint: l10n.enterMapLocation,
                  required: false,
                ),
              ],
              theme,
            ),

            const SizedBox(height: 24),

            // Contact Information Section
            _buildSection(
              l10n.contactInformation,
              Icons.contact_phone,
              [
                _buildTextField(
                  controller: _phoneController,
                  label: l10n.phoneNumber,
                  hint: l10n.enterPhoneNumber,
                  required: true,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: l10n.email,
                  hint: l10n.enterEmail,
                  required: false,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
              theme,
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const WMSLoadingIndicator(size: 20)
                    : Text(
                        _isEditMode ? l10n.updateStore : l10n.createStore,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    List<Widget> children,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool required,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: required
          ? (value) {
              if (value?.trim().isEmpty ?? true) {
                final l10n = AppLocalizations.of(context)!;
                return l10n.fieldRequired;
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildStatusField(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.status,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: Text(l10n.active),
                value: true,
                groupValue: _isActive,
                onChanged: (value) => setState(() => _isActive = value!),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text(l10n.inactive),
                value: false,
                groupValue: _isActive,
                onChanged: (value) => setState(() => _isActive = value!),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time != null ? _formatTimeOfDay(time) : '--:--',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.access_time,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}