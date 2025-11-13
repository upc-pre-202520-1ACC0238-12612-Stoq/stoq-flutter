import 'package:flutter/material.dart';
import '../../auth/models/login_response.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/logo_widget.dart';
import '../../profile/screens/profile_screen.dart';
import '../../inventory/screens/inventory_screen.dart';
import '../../inventory/screens/branches_map_screen.dart';
import '../../inventory/models/branch_model.dart';
import '../../inventory/screens/multi_branch_inventory_screen.dart';
import '../../dashboard/screens/scan_product_screen.dart';
import '../../inventory/screens/inventory_management_screen.dart';
import '../../products/screens/products_screen.dart';
import '../../inventory/services/inventory_service.dart';
import '../../inventory/models/inventory_models.dart';

class DashboardTabsScreen extends StatefulWidget {
  final LoginResponse user;

  const DashboardTabsScreen({super.key, required this.user});

  @override
  State<DashboardTabsScreen> createState() => _DashboardTabsScreenState();
}

class _DashboardTabsScreenState extends State<DashboardTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InventoryService _inventoryService = InventoryService();
  
  // Datos desde la API
  List<InventoryProduct> _inventoryProducts = [];
  List<InventoryBatch> _inventoryBatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Ahora 3 pestañas
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final inventory = await _inventoryService.getInventory();
      setState(() {
        _inventoryProducts = inventory.productos;
        _inventoryBatches = inventory.lotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos del dashboard: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Calcular estadísticas desde los datos reales
  int get _totalProducts => _inventoryProducts.length;
  int get _totalStock => _inventoryProducts.fold(0, (sum, p) => sum + p.cantidad);
  int get _lowStockCount => _inventoryProducts.where((p) => p.stockBajo).length;
  double get _totalValue => _inventoryProducts.fold(0.0, (sum, p) => sum + p.total);
  
  // Obtener próxima fecha de entrada (más reciente)
  String get _nextDeliveryDate {
    if (_inventoryBatches.isEmpty) return 'N/A';
    final sortedBatches = List<InventoryBatch>.from(_inventoryBatches)
      ..sort((a, b) => b.fechaEntrada.compareTo(a.fechaEntrada));
    final nextBatch = sortedBatches.first;
    return '${nextBatch.fechaEntrada.day.toString().padLeft(2, '0')}/${nextBatch.fechaEntrada.month.toString().padLeft(2, '0')}/${nextBatch.fechaEntrada.year}';
  }

  // Obtener productos recientes (últimos 3)
  List<InventoryProduct> get _recentProducts {
    final sorted = List<InventoryProduct>.from(_inventoryProducts)
      ..sort((a, b) => b.fechaEntrada.compareTo(a.fechaEntrada));
    return sorted.take(3).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userName: '${widget.user.name} ${widget.user.lastName}',
          userRole: widget.user.role,
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente'),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(AppSizes.paddingSmall),
          child: LogoWidget(size: 40),
        ),
        title: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Inicio'),
            Tab(text: 'Inventario'),
            Tab(text: 'Mapa'),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('${widget.user.name} ${widget.user.lastName}'),
                  subtitle: Text(widget.user.role),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToProfile();
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar sesión'),
                  onTap: () {
                    Navigator.pop(context);
                    _signOut();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // PESTAÑA 1: Dashboard Principal (Inicio)
          _buildHomeTab(),

          // PESTAÑA 2: Gestión de Inventario
          _buildInventoryTab(),

          // PESTAÑA 3: Vista de Mapa
          BranchesMapScreen(
            onBranchSelected: (branch) {
              _navigateToBranchInventory(branch);
            },
          ),
        ],
      ),
    );
  }

  // PESTAÑA 1: Dashboard Principal (Inicio)
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          // Tarjetas de estadísticas
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatsCard(
                            icon: Icons.inventory_2_outlined,
                            title: 'Productos Totales',
                            value: '$_totalProducts',
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatsCard(
                            icon: Icons.calendar_today,
                            title: 'Próxima Entrega',
                            value: _nextDeliveryDate,
                            color: AppColors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatsCard(
                            icon: Icons.warning,
                            title: 'Stock Bajo',
                            value: '$_lowStockCount',
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatsCard(
                            icon: Icons.business,
                            title: 'Sedes Activas',
                            value: '${Branch.sampleBranches.length}',
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 25),

          // Botones de acción rápida
          _buildActionButton(
            icon: Icons.add_box,
            text: 'Agregar Productos',
            color: AppColors.redAccent,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildActionButton(
            icon: Icons.shopping_cart,
            text: 'Kits de Productos',
            color: AppColors.primary,
            onPressed: () => _showComingSoon('Kits de Productos'),
          ),
          const SizedBox(height: 15),
          _buildActionButton(
            icon: Icons.assignment_return,
            text: 'Devoluciones',
            color: AppColors.primary,
            onPressed: () => _showComingSoon('Devoluciones'),
          ),
          const SizedBox(height: 25),

          const SizedBox(height: 15),

        // BOTÓN: Escanear Producto
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanProductScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                elevation: 3,
              ),
              icon: const Icon(Icons.camera_alt, color: AppColors.textLight, size: 24),
              label: const Text(
                'Escanear Producto',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Lista de productos recientes
          const Text(
            'Productos Recientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              : _recentProducts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No hay productos recientes',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: _recentProducts.map((producto) {
                        final fecha = '${producto.fechaEntrada.day.toString().padLeft(2, '0')}/${producto.fechaEntrada.month.toString().padLeft(2, '0')}/${producto.fechaEntrada.year}';
                        return _buildProductCard(
                          nombre: producto.productoNombre,
                          fecha: fecha,
                          stock: producto.cantidad,
                        );
                      }).toList(),
                    ),
        ],
      ),
      ),
    );
  }

  // PESTAÑA 2: Gestión de Inventario
  Widget _buildInventoryTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          // Tarjetas de resumen rápido de inventario
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildQuickStatsCard(
                        icon: Icons.warehouse,
                        title: 'Stock Total',
                        value: _totalStock.toString(),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildQuickStatsCard(
                        icon: Icons.category,
                        title: 'Productos',
                        value: '$_totalProducts',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),

          const SizedBox(height: 20),

          // Botón de Inventario Multi-sede
          SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.warehouse, color: AppColors.primary, size: 30),
                title: const Text(
                  'Inventario Multi-sede',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                subtitle: const Text('Gestión de stock por sede'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MultiBranchInventoryScreen(),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Botón rápido al inventario tradicional
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.analytics, size: 24, color: AppColors.redAccent),
              label: const Text(
                'Ver Inventario por Producto',
                style: TextStyle(fontSize: 16,color: AppColors.redAccent,
        fontWeight: FontWeight.bold,),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textLight,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  side: BorderSide(color: AppColors.primary, width: 1),
                ),
                elevation: 2
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Acciones rápidas de inventario
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildInventoryAction(
                icon: Icons.swap_horiz,
                title: 'Transferir',
                color: AppColors.info,
                onTap: () => _showComingSoon('Transferencias'),
              ),
              _buildInventoryAction(
                icon: Icons.edit,
                title: 'Ajustar Stock',
                color: AppColors.warning,
                onTap: () => _showComingSoon('Ajustar Stock'),
              ),
              _buildInventoryAction(
                icon: Icons.history,
                title: 'Historial',
                color: AppColors.success,
                onTap: () => _showComingSoon('Historial'),
              ),
              _buildInventoryAction(
                icon: Icons.report,
                title: 'Reportes',
                color: AppColors.redAccent,
                onTap: () => _showComingSoon('Reportes'),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  // Widgets reutilizables del dashboard original
  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (value.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          elevation: 3,
        ),
        icon: Icon(icon, color: AppColors.textLight),
        label: Text(
          text,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String nombre,
    required String fecha,
    required int stock,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  fecha,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Stock',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  stock.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widgets del nuevo dashboard
  Widget _buildQuickStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBranchInventory(Branch branch) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryManagementScreen(
          inventoryName: 'Inventario ${branch.name}',
          branch: branch,
        ),
      ),
    );
  }
}