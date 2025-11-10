import 'package:flutter/material.dart';
import '../../auth/models/login_response.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';

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
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.inventory_2,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Stock Wise',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('${widget.user.name} ${widget.user.lastName}'),
                  subtitle: Text(widget.user.role),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Tarjetas de estadísticas superiores
              Row(
                children: [
                  Expanded(
                    child: _buildStatsCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Total Productos',
                      value: '500',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatsCard(
                      icon: Icons.calendar_today,
                      title: 'Fecha Provedor',
                      value: '00/00/00',
                      color: Colors.purple,
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
                      title: 'Historial Movimientos',
                      value: '',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatsCard(
                      icon: Icons.storage,
                      title: 'Inventario',
                      value: '',
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              
              // Botones de acción
              _buildActionButton(
                icon: Icons.add_box,
                text: 'Agregar Productos',
                color: const Color(0xFFDC2626),
                onPressed: () {
                  // TODO: Navegar a agregar productos
                  _showComingSoon('Agregar Productos');
                },
              ),
              const SizedBox(height: 15),
              _buildActionButton(
                icon: Icons.shopping_cart,
                text: 'Kits Productos',
                color: const Color(0xFFEA580C),
                onPressed: () {
                  // TODO: Navegar a kits productos
                  _showComingSoon('Kits Productos');
                },
              ),
              const SizedBox(height: 15),
              _buildActionButton(
                icon: Icons.assignment_return,
                text: 'Devolución Productos',
                color: const Color(0xFFEA580C),
                onPressed: () {
                  // TODO: Navegar a devoluciones
                  _showComingSoon('Devolución Productos');
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
              color: Colors.black87,
            ),
          ),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 3,
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200, width: 2),
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
                    color: Colors.black87,
                  ),
                ),
                Text(
                  fecha,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2,
                  size: 16,
                  color: Colors.orange.shade700,
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
        content: Text('$feature - Próximamente'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}