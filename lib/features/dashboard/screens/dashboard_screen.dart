import 'package:flutter/material.dart';
import '../../auth/models/login_response.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/logo_widget.dart';
import '../../profile/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final LoginResponse user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Datos de ejemplo para el dashboard
  final List<Map<String, dynamic>> productos = [
    {
      'nombre': 'Leche',
      'fecha': '15/05/2024',
      'stock': 5,
    },
    {
      'nombre': 'Pan',
      'fecha': '16/05/2024',
      'stock': 12,
    },
    {
      'nombre': 'Arroz',
      'fecha': '14/05/2024',
      'stock': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(AppSizes.paddingSmall),
          child: LogoWidget(size: 80),
        ),
        title: const Text(''), 
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
                    Future.delayed(Duration.zero, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            userName: '${widget.user.name} ${widget.user.lastName}',
                            userRole: widget.user.role,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar sesión'),
                  onTap: () async {
                    Navigator.pop(context);
                    await AuthService().signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            children: [
            
              Row(
                children: [
                  Expanded(
                    child: _buildStatsCard(
                      icon: Icons.inventory_2_outlined,
                      title: AppStrings.totalProducts,
                      value: '500',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatsCard(
                      icon: Icons.calendar_today,
                      title: AppStrings.providerDate,
                      value: '00/00/00',
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
                      icon: Icons.trending_up,
                      title: AppStrings.movementHistory,
                      value: '',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatsCard(
                      icon: Icons.storage,
                      title: AppStrings.inventory,
                      value: '',
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              
              // Botones de acción
              _buildActionButton(
                icon: Icons.add_box,
                text: AppStrings.addProducts,
                color: AppColors.redAccent,
                onPressed: () {
                  _showComingSoon(AppStrings.addProducts);
                },
              ),
              const SizedBox(height: 15),
              _buildActionButton(
                icon: Icons.shopping_cart,
                text: AppStrings.kitsProducts,
                color: AppColors.primary,
                onPressed: () {
                  _showComingSoon(AppStrings.kitsProducts);
                },
              ),
              const SizedBox(height: 15),
              _buildActionButton(
                icon: Icons.assignment_return,
                text: AppStrings.returnProducts,
                color: AppColors.primary,
                onPressed: () {
                  _showComingSoon(AppStrings.returnProducts);
                },
              ),
              const SizedBox(height: 25),
              
              // Lista de productos
              Column(
                children: productos.map((producto) => _buildProductCard(
                  nombre: producto['nombre'],
                  fecha: producto['fecha'],
                  stock: producto['stock'],
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - ${AppStrings.comingSoon}'),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}