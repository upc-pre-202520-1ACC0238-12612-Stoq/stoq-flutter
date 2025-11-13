import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(-12.0464, -77.0428);
  Branch? _selectedBranch;
  bool _mapError = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // En web, Google Maps puede tener problemas, mostrar lista directamente
    // En otras plataformas, intentar mostrar el mapa
    _mapError = kIsWeb;
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
        
        // Mapa o Lista alternativa
        Expanded(
          child: _mapError
              ? _buildBranchesList()
              : Builder(
                  builder: (context) {
                    return Stack(
                      children: [
                        // Intentar mostrar el mapa, si falla mostrar lista
                        _buildMapOrList(),
                        
                        // Panel de sede seleccionada
                        if (_selectedBranch != null)
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: _buildBranchCard(_selectedBranch!),
                          ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMapOrList() {
    // Si hay error conocido, mostrar lista directamente
    if (_mapError) {
      return _buildBranchesList();
    }

    // Intentar mostrar el mapa con manejo de errores
    // Si Google Maps no está disponible, se mostrará la lista automáticamente
    try {
      return GoogleMap(
        key: const ValueKey('branches_map'),
        onMapCreated: (controller) {
          try {
            _onMapCreated(controller);
          } catch (e) {
            // Si falla al crear el mapa, mostrar lista
            if (mounted) {
              setState(() {
                _mapError = true;
              });
            }
          }
        },
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 12.0,
        ),
        markers: _createMarkers(),
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        onTap: (LatLng position) {
          setState(() {
            _selectedBranch = null;
          });
        },
        mapType: MapType.normal,
        onCameraMoveStarted: () {},
      );
    } catch (e) {
      // Si hay error al construir el mapa, mostrar lista
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _mapError = true;
          });
        }
      });
      return _buildBranchesList();
    }
  }

  Widget _buildBranchesList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          color: AppColors.warning.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mapa no disponible. Mostrando lista de sedes.',
                  style: TextStyle(color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: Branch.sampleBranches.length,
            itemBuilder: (context, index) {
              final branch = Branch.sampleBranches[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
                child: ListTile(
                  leading: Icon(branch.typeIcon, color: branch.alertColor),
                  title: Text(branch.name),
                  subtitle: Text('${branch.address}\nStock: ${branch.stockTotal}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    widget.onBranchSelected?.call(branch);
                  },
                ),
              );
            },
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
    try {
      return Branch.sampleBranches.map((branch) {
        return Marker(
          markerId: MarkerId(branch.id),
          position: LatLng(branch.latitude, branch.longitude),
          infoWindow: InfoWindow(
            title: branch.name,
            snippet: 'Stock: ${branch.stockTotal}',
          ),
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            setState(() {
              _selectedBranch = branch;
            });
          },
        );
      }).toSet();
    } catch (e) {
      // Si hay error con los marcadores, mostrar lista
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _mapError = true;
          });
        }
      });
      return {};
    }
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
