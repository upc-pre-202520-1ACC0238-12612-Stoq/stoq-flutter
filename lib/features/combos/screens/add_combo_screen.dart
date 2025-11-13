import 'package:flutter/material.dart';
import '../models/combo_models.dart';
import '../services/combo_service.dart';
import '../../products/models/product_models.dart';

class AddComboScreen extends StatefulWidget {
  final List<Product> availableProducts;

  const AddComboScreen({
    super.key,
    required this.availableProducts,
  });

  @override
  State<AddComboScreen> createState() => _AddComboScreenState();
}

class _AddComboScreenState extends State<AddComboScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ComboService _comboService = ComboService();
  
  List<ComboItemRequest> selectedItems = [];
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => _ProductSelectionDialog(
        availableProducts: widget.availableProducts,
        onProductSelected: (productId, quantity) {
          setState(() {
            final existingIndex = selectedItems.indexWhere(
              (item) => item.productId == productId,
            );
            
            if (existingIndex >= 0) {
              selectedItems[existingIndex] = ComboItemRequest(
                productId: productId,
                quantity: selectedItems[existingIndex].quantity + quantity,
              );
            } else {
              selectedItems.add(ComboItemRequest(
                productId: productId,
                quantity: quantity,
              ));
            }
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _removeProduct(int index) {
    setState(() {
      selectedItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        selectedItems.removeAt(index);
      } else {
        selectedItems[index] = ComboItemRequest(
          productId: selectedItems[index].productId,
          quantity: newQuantity,
        );
      }
    });
  }

  Product? _getProductById(int productId) {
    try {
      return widget.availableProducts.firstWhere(
        (product) => product.id == productId,
      );
    } catch (e) {
      return null;
    }
  }

  double _calculateTotalPrice() {
    double total = 0.0;
    for (final item in selectedItems) {
      final product = _getProductById(item.productId);
      if (product != null) {
        total += product.salePrice * item.quantity;
      }
    }
    return total;
  }

  Future<void> _saveCombo() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos un producto al combo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final comboRequest = ComboRequest(
        name: _nameController.text.trim(),
        items: selectedItems,
      );

      await _comboService.createCombo(comboRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Combo creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear combo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Kit de Productos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton.icon(
            onPressed: isLoading ? null : _saveCombo,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Información del combo
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Kit',
                      hintText: 'Ej: Kit Desayuno Premium',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.shopping_cart,
                          title: 'Productos',
                          value: selectedItems.length.toString(),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.attach_money,
                          title: 'Total',
                          value: 'S/ ${_calculateTotalPrice().toStringAsFixed(2)}',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Lista de productos seleccionados
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Productos del Kit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addProduct,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: selectedItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_shopping_cart,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Agrega productos al kit',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Presiona el botón "Agregar" para incluir productos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: selectedItems.length,
                            itemBuilder: (context, index) {
                              final item = selectedItems[index];
                              final product = _getProductById(item.productId);
                              
                              if (product == null) {
                                return const SizedBox.shrink();
                              }
                              
                              return _ProductCard(
                                product: product,
                                quantity: item.quantity,
                                onQuantityChanged: (newQuantity) =>
                                    _updateQuantity(index, newQuantity),
                                onRemove: () => _removeProduct(index),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'S/ ${product.salePrice.toStringAsFixed(2)} c/u',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subtotal: S/ ${(product.salePrice * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: quantity > 1
                      ? () => onQuantityChanged(quantity - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => onQuantityChanged(quantity + 1),
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSelectionDialog extends StatefulWidget {
  final List<Product> availableProducts;
  final Function(int productId, int quantity) onProductSelected;

  const _ProductSelectionDialog({
    required this.availableProducts,
    required this.onProductSelected,
  });

  @override
  State<_ProductSelectionDialog> createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<_ProductSelectionDialog> {
  Product? selectedProduct;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Producto'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Product>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Producto',
                border: OutlineInputBorder(),
              ),
              items: widget.availableProducts.map((product) {
                return DropdownMenuItem<Product>(
                  value: product,
                  child: Text(
                    '${product.name} - S/ ${product.salePrice.toStringAsFixed(2)}',
                  ),
                );
              }).toList(),
              onChanged: (Product? value) {
                setState(() {
                  selectedProduct = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Cantidad: '),
                IconButton(
                  onPressed: quantity > 1
                      ? () => setState(() => quantity--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => quantity++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: selectedProduct != null
              ? () => widget.onProductSelected(selectedProduct!.id, quantity)
              : null,
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}