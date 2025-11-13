import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../models/product_models.dart';
import '../services/product_service.dart';

class AddProductModal extends StatefulWidget {
  final Function(Product) onProductAdded;

  const AddProductModal({
    super.key,
    required this.onProductAdded,
  });

  @override
  State<AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> {
  final ProductService _productService = ProductService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para los campos del formulario
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _notesController = TextEditingController();

  // Variables de estado
  List<Tag> _availableTags = [];
  List<Tag> _selectedTags = [];
  bool _isLoading = false;
  bool _isLoadingTags = true;
  
  // Variables para categorías y unidades (simuladas por ahora)
  final List<String> _categories = ['Alimentos', 'Bebidas', 'Dulces', 'Snacks', 'Otros'];
  final List<String> _units = ['Unidad', 'Kilogramo', 'Litro', 'Gramo', 'Metro'];
  
  String? _selectedCategory;
  String? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    try {
      final tags = await _productService.getTags();
      setState(() {
        _availableTags = tags;
        _isLoadingTags = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTags = false;
      });
    }
  }

  void _toggleTag(Tag tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      _showErrorMessage('Por favor selecciona una categoría');
      return;
    }

    if (_selectedUnit == null) {
      _showErrorMessage('Por favor selecciona una unidad');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productRequest = ProductRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        purchasePrice: double.parse(_purchasePriceController.text),
        salePrice: double.parse(_salePriceController.text),
        categoryId: _getCategoryId(_selectedCategory!),
        unitId: _getUnitId(_selectedUnit!),
        tagIds: _selectedTags.map((tag) => tag.id).toList(),
        internalNotes: _notesController.text.trim(),
      );

      final product = await _productService.createProduct(productRequest);
      
      widget.onProductAdded(product);
      Navigator.pop(context);
      
    } catch (e) {
      _showErrorMessage('Error al crear el producto: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _getCategoryId(String category) {
    // En una implementación real, esto vendría de la API
    final categoryMap = {
      'Alimentos': 1,
      'Bebidas': 2,
      'Dulces': 3,
      'Snacks': 4,
      'Otros': 5,
    };
    return categoryMap[category] ?? 1;
  }

  int _getUnitId(String unit) {
    // En una implementación real, esto vendría de la API
    final unitMap = {
      'Unidad': 1,
      'Kilogramo': 2,
      'Litro': 3,
      'Gramo': 4,
      'Metro': 5,
    };
    return unitMap[unit] ?? 1;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header del modal
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
                const Expanded(
                  child: Text(
                    'Agregar Producto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Para balancear el botón de cerrar
              ],
            ),
          ),
          
          // Formulario
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del producto
                    const Text(
                      'Nombre del Producto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Ej: Galleta Oreo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Descripción
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Descripción del producto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Precios
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Precio de Compra',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _purchasePriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Precio obligatorio';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Precio inválido';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Precio de Venta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _salePriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Precio obligatorio';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Precio inválido';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Categoría y Unidad
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Categoría',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Selecciona categoría',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                  ),
                                ),
                                items: _categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Unidad',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedUnit,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUnit = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Selecciona unidad',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                  ),
                                ),
                                items: _units.map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Tags
                    const Text(
                      'Etiquetas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingTags
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _availableTags.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'No hay etiquetas disponibles',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableTags.map((tag) {
                                  final isSelected = _selectedTags.contains(tag);
                                  return FilterChip(
                                    label: Text(tag.name),
                                    selected: isSelected,
                                    onSelected: (_) => _toggleTag(tag),
                                    selectedColor: AppColors.primary.withOpacity(0.2),
                                    checkmarkColor: AppColors.primary,
                                  );
                                }).toList(),
                              ),
                    
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Notas internas
                    const Text(
                      'Notas Internas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Notas para uso interno...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingLarge),
                    
                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redAccent,
                          foregroundColor: AppColors.textLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Guardando...'),
                                ],
                              )
                            : const Text(
                                'Guardar Producto',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}