import 'package:flutter/material.dart';
import '../models/branch_model.dart';
import '../../../shared/constants/app_constants.dart';

class SedesMapScreen extends StatefulWidget {
  final List<Branch> branches;

  const SedesMapScreen({
    super.key,
    required this.branches,
  });

  @override
  State<SedesMapScreen> createState() => _SedesMapScreenState();
}

class _SedesMapScreenState extends State<SedesMapScreen> {
  Branch? _selectedBranch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Seleccionar Sede',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Información de la sede seleccionada
          if (_selectedBranch != null)
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              color: AppColors.cardBackground,
              child: Row(
                children: [
                  Icon(
                    _selectedBranch!.typeIcon,
                    color: _selectedBranch!.alertColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedBranch!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _selectedBranch!.address,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedBranch);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'Seleccionar',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ),
                ],
              ),
            ),
          
          // Lista de sedes
          Expanded(
            child: _buildBranchesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: widget.branches.length,
      itemBuilder: (context, index) {
        final branch = widget.branches[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
          child: ListTile(
            leading: Icon(
              branch.typeIcon,
              color: branch.alertColor,
            ),
            title: Text(
              branch.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(branch.address),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 16,
                      color: branch.alertColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stock: ${branch.stockTotal}',
                      style: TextStyle(
                        color: branch.alertColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: branch.alertColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${branch.latitude.toStringAsFixed(4)}, ${branch.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                _selectedBranch = branch;
              });
            },
          ),
        );
      },
    );
  }
}