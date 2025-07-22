import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../generated/app_localizations.dart';

import '../../../core/models/category.dart';
import '../../../core/models/store.dart';
import '../../../core/models/api_requests.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/store_service.dart';
import '../../../core/providers/store_context_provider.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({
    super.key,
    this.category,
  });

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final CategoryService _categoryService = CategoryService();
  final StoreService _storeService = StoreService();
  
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  List<Store> _stores = [];
  String? _selectedStoreId;

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.category!.name;
      _selectedStoreId = widget.category!.storeId;
    }
    _loadStores();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    // Guard clause: ensure widget is mounted
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _storeService.getStores();
      
      // Guard clause: check if widget is still mounted after async operation
      if (!mounted) return;
      
      setState(() {
        _stores = response.data;
        _isLoading = false;
        
        // Auto-select current store if only one available and no selection made
        if (_selectedStoreId == null && response.data.length == 1) {
          _selectedStoreId = response.data.first.id;
        }
      });
    } catch (e) {
      // Guard clause: ensure widget is mounted before updating state
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCategory() async {
    // Guard clause: validate form before proceeding
    if (!_formKey.currentState!.validate()) return;
    
    // Guard clause: ensure store is selected
    if (_selectedStoreId == null) {
      // Guard clause: ensure widget is mounted before showing snackbar
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectStore),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      Category result;
      
      if (isEditing) {
        final request = UpdateCategoryRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
        );
        result = await _categoryService.updateCategory(widget.category!.id, request);
      } else {
        final request = CreateCategoryRequest(
          name: _nameController.text.trim(),
          storeId: _selectedStoreId!,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
        );
        result = await _categoryService.createCategory(request);
      }

      // Guard clause: ensure widget is mounted after async operation
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing 
              ? AppLocalizations.of(context)!.categoryUpdatedSuccessfully
              : AppLocalizations.of(context)!.categoryCreatedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(result);
    } catch (e) {
      // Guard clause: ensure widget is mounted before updating error state
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storeProvider = context.watch<StoreContextProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editCategory : l10n.createCategory,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    l10n.loading,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    _buildHeaderCard(l10n),
                    
                    SizedBox(height: 24),
                    
                    // Form Card
                    _buildFormCard(l10n, storeProvider),
                    
                    SizedBox(height: 24),
                    
                    // Error Display
                    if (_error != null) _buildErrorCard(),
                    
                    SizedBox(height: 32),
                    
                    // Save Button
                    _buildSaveButton(l10n),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing ? Icons.edit : Icons.add_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? l10n.editCategoryTitle : l10n.createCategoryTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 4),
                Text(
                  isEditing 
                      ? l10n.editCategoryDescription
                      : l10n.createCategoryDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(AppLocalizations l10n, StoreContextProvider storeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Selection Dropdown
          _buildStoreSelectionSection(l10n, storeProvider),
          
          SizedBox(height: 20),
          
          // Category Name Field
          _buildNameField(l10n),
          
          SizedBox(height: 16),
          
          // Description Field
          _buildDescriptionField(l10n),
        ],
      ),
    );
  }

  Widget _buildStoreSelectionSection(AppLocalizations l10n, StoreContextProvider storeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.store,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        
        if (_stores.isEmpty) ...[
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.noStoresAvailable,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedStoreId ?? storeProvider.selectedStore?.id,
              decoration: InputDecoration(
                labelText: l10n.selectStore,
                prefixIcon: Icon(Icons.store, color: Theme.of(context).colorScheme.primary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _stores.map((store) {
                return DropdownMenuItem<String>(
                  value: store.id,
                  child: Text(
                    store.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                // Guard clause: ensure widget is mounted before state update
                if (!mounted) return;
                
                setState(() {
                  _selectedStoreId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return l10n.pleaseSelectStore;
                }
                return null;
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNameField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.categoryName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.categoryNameLabel,
            hintText: l10n.categoryNameHint,
            prefixIcon: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.categoryNameRequired;
            }
            if (value.trim().length < 2) {
              return l10n.categoryNameMinLength;
            }
            if (value.trim().length > 100) {
              return l10n.categoryNameMaxLength;
            }
            return null;
          },
          enabled: !_isSaving,
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildDescriptionField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.description,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: l10n.descriptionOptional,
            hintText: l10n.categoryDescriptionHint,
            prefixIcon: Icon(Icons.description, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          maxLines: 4,
          maxLength: 500,
          validator: (value) {
            if (value != null && value.trim().length > 500) {
              return l10n.descriptionMaxLength;
            }
            return null;
          },
          enabled: !_isSaving,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveCategory,
        icon: _isSaving 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(isEditing ? Icons.save : Icons.add),
        label: Text(
          _isSaving ? l10n.saving : (isEditing ? l10n.updateCategory : l10n.createCategory),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}