import 'package:flutter/material.dart';
import '../models/combo_models.dart';
import '../services/combo_service.dart';
import 'add_combo_screen.dart';
import '../../products/models/product_models.dart';
import '../../products/services/product_service.dart';

class CombosScreen extends StatefulWidget {
  const CombosScreen({super.key});

  @override
  State<CombosScreen> createState() => _CombosScreenState();
}

class _CombosScreenState extends State<CombosScreen> {
  final ComboService _comboService = ComboService();
  final ProductService _productService = ProductService();
  List<Combo> combos = [];
  List<Product> availableProducts = [];
  bool isLoading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final [combosResult, productsResult] = await Future.wait([
        _comboService.getCombos(),
        _productService.getProducts(),
      ]);
      
      setState(() {
        combos = combosResult as List<Combo>;
        availableProducts = productsResult as List<Product>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
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

  Future<void> _refreshCombos() async {
    await _loadData();
  }

  List<Combo> get filteredCombos {
    if (searchQuery.isEmpty) return combos;
    
    return combos.where((combo) {
      return combo.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kits de Productos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCombos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar combos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          
          // Lista de combos
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCombos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No hay combos registrados'
                                  : 'No se encontraron combos',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              searchQuery.isEmpty
                                  ? 'Agrega tu primer combo usando el botón +'
                                  : 'Intenta con otro término de búsqueda',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshCombos,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredCombos.length,
                          itemBuilder: (context, index) {
                            final combo = filteredCombos[index];
                            return _buildComboCard(combo);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddComboScreen(
                availableProducts: availableProducts,
              ),
            ),
          );
          
          if (result == true) {
            _refreshCombos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildComboCard(Combo combo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2,
            color: Colors.orange[700],
            size: 28,
          ),
        ),
        title: Text(
          combo.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${combo.totalItems} productos',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, size: 14, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text(
                  'S/ ${combo.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text(
                  'Productos incluidos:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...combo.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.productName} x${item.quantity}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        'S/ ${(item.productPrice * item.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}