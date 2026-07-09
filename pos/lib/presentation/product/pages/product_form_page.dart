import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../category/bloc/category_bloc.dart';
import '../../category/bloc/category_event.dart';
import '../../category/bloc/category_state.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _descController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _selectedCategoryId = widget.product?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final product = ProductModel(
      id: widget.product?.id,
      categoryId: _selectedCategoryId!,
      name: _nameController.text.trim(),
      sku: _skuController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
    );

    if (widget.product != null) {
      context
          .read<ProductBloc>()
          .add(UpdateProduct(widget.product!.id!, product));
    } else {
      context.read<ProductBloc>().add(CreateProduct(product));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Product' : 'Add Product')),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
          }
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withAlpha(20),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        BlocBuilder<CategoryBloc, CategoryState>(
                          builder: (context, state) {
                            List<CategoryModel> categories = [];
                            if (state is CategoriesLoaded) {
                              categories = state.categories;
                            }
                            return DropdownButtonFormField<int>(
                              initialValue: _selectedCategoryId,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: categories
                                  .map((c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCategoryId = v),
                              validator: (v) =>
                                  v == null ? 'Category is required' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.shopping_bag_outlined),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _skuController,
                          decoration: const InputDecoration(
                            labelText: 'SKU',
                            prefixIcon: Icon(Icons.qr_code),
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'SKU is required' : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            prefixText: 'Rp ',
                            prefixIcon: Icon(Icons.monetization_on_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                              if (v?.isEmpty ?? true) return 'Price is required';
                              if (double.tryParse(v!) == null) return 'Invalid number';
                              return null;
                            },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stock',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                              if (v?.isEmpty ?? true) return 'Stock is required';
                              if (int.tryParse(v!) == null) return 'Invalid number';
                              return null;
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    return GlassButton(
                      label: 'Save',
                      icon: Icons.save,
                      loading: state is ProductLoading,
                      onPressed: state is ProductLoading ? null : _save,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}