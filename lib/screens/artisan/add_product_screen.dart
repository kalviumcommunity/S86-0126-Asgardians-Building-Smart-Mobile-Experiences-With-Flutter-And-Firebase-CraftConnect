import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_localizations.dart';
import 'dart:io';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../providers/product_provider.dart';
import '../../utils/image_helper.dart';
import '../../utils/validators.dart';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';

class AddProductScreen extends StatefulWidget {
  final String shopId;
  final ProductModel? product;
  const AddProductScreen({super.key, required this.shopId, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  File? _imageFile;
  double? _imageSizeInMB;
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await ImageHelper.pickImage(
      source: ImageSource.gallery,
      maxSizeInMB: 5.0,
    );

    if (result.isValid && result.file != null) {
      setState(() {
        _imageFile = result.file;
        _imageSizeInMB = result.fileSizeInMB;
      });
      if (mounted) {
        ImageHelper.showSuccess(
          context,
          'Image selected (${ImageHelper.formatFileSize(result.fileSizeInMB!)})',
        );
      }
    } else if (result.errorMessage != null && mounted) {
      ImageHelper.showValidationError(context, result.errorMessage!);
    }
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = _isEditing
        ? await productProvider.updateProduct(
            product: widget.product!.copyWith(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              price: double.parse(_priceController.text.trim()),
              stock: int.parse(_stockController.text.trim()),
            ),
            newImageFile: _imageFile,
          )
        : await productProvider.addProduct(
            shopId: widget.shopId,
            artisanId: authProvider.currentUser?.uid ?? '',
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: double.parse(_priceController.text.trim()),
            stock: int.parse(_stockController.text.trim()),
            imageFile: _imageFile,
          );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully! 🎉'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      // Navigate back - use go if pop fails
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/artisan/dashboard');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            productProvider.errorMessage ?? 'Failed to add product',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : l10n.product_add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: (_imageFile != null ||
                          (_isEditing && widget.product?.imageUrl != null))
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: _imageFile != null
                                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                                  : Image.network(
                                      widget.product!.imageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            if (_imageSizeInMB != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    ImageHelper.formatFileSize(_imageSizeInMB!),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 64,
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const Text(
                              'Add Product Image',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.product_name,
                  prefixIcon: const Icon(Icons.shopping_bag),
                  hintText: 'e.g., Handmade Vase',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.error_requiredField;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.product_description,
                  prefixIcon: const Icon(Icons.description),
                  hintText: 'Describe your product...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.error_requiredField;
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: l10n.product_price,
                  prefixIcon: const Icon(Icons.currency_rupee),
                  hintText: '1500',
                  helperText: 'Min ₹1, Max ₹999,999',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => Validators.validatePrice(
                  value,
                  min: 1,
                  max: 999999,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Stock
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: l10n.product_stock,
                  prefixIcon: const Icon(Icons.inventory),
                  hintText: '10',
                  helperText: 'Available quantity',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validateQuantity(
                  value,
                  min: 0,
                  max: 10000,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Add Button
              Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  return ElevatedButton(
                    onPressed: productProvider.isLoading ? null : _addProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: productProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(_isEditing ? 'Save Changes' : l10n.product_add),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
