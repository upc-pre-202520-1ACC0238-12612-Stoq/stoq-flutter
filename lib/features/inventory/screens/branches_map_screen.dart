import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/branch_model.dart';
import '../../../shared/constants/app_constants.dart';

class BranchesMapScreen extends StatefulWidget {
  final Function(Branch)? onBranchSelected;

  const BranchesMapScreen({super.key, this.onBranchSelected});

  @override
  State<BranchesMapScreen> createState() => _BranchesMapScreenState();
}

class _BranchesMapScreenState extends State<BranchesMapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(-12.0464, -77.0428);
  Branch? _selectedBranch;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header informativo
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          color: AppColors.cardBackground,
          child: Row(
            children: [
              _buildLegendItem(Colors.green, 'Stock Bueno'),
              _buildLegendItem(Colors.orange, 'Stock Medio'),
              _buildLegendItem(Colors.red, 'Stock Crítico'),
            ],
          ),
        ),
        
        // Mapa
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 12.0,
                ),
                markers: _createMarkers(),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              
              // Panel de sede seleccionada
              if (_selectedBranch != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _buildBranchCard(_selectedBranch!),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Set<Marker> _createMarkers() {
    return Branch.sampleBranches.map((branch) {
      return Marker(
        markerId: MarkerId(branch.id),
        position: LatLng(branch.latitude, branch.longitude),
        infoWindow: InfoWindow(
          title: branch.name,
          snippet: 'Stock: ${branch.stockTotal}',
        ),
        icon: _getMarkerIcon(branch),
        onTap: () {
          setState(() {
            _selectedBranch = branch;
          });
        },
      );
    }).toSet();
  }

  BitmapDescriptor _getMarkerIcon(Branch branch) {
    // En una implementación real, generarías iconos diferentes por color
    // Por simplicidad, usamos el marcador por defecto
    return BitmapDescriptor.defaultMarker;
  }

  Widget _buildBranchCard(Branch branch) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(branch.typeIcon, color: branch.alertColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    branch.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.inventory_2,
                  color: branch.alertColor,
                ),
                const SizedBox(width: 5),
                Text(
                  branch.stockTotal.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: branch.alertColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              branch.address,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onBranchSelected?.call(branch);
                  setState(() {
                    _selectedBranch = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Ver Inventario de esta Sede'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
