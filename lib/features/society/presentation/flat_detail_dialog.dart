import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/flat.dart';
import '../domain/floor.dart';
import '../domain/tower.dart';

class FlatDetailDialog extends StatelessWidget {
  final Flat flat;
  final Tower? tower;
  final Floor? floor;

  const FlatDetailDialog({
    super.key,
    required this.flat,
    this.tower,
    this.floor,
  });

  static void show(
    BuildContext context, {
    required Flat flat,
    Tower? tower,
    Floor? floor,
  }) {
    showDialog(
      context: context,
      builder: (context) => FlatDetailDialog(
        flat: flat,
        tower: tower,
        floor: floor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.home_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Flat ${flat.flatNumber} Details',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDetailTile(
              context,
              'Occupancy Status',
              StatusBadge.fromStatus(flat.occupancyStatus.code),
            ),
            const Divider(height: 20),
            _buildInfoRow('Flat Type', flat.flatType.displayName),
            const SizedBox(height: 12),
            _buildInfoRow('Area', Formatters.formatArea(flat.areaSqFt)),
            const SizedBox(height: 12),
            _buildInfoRow('Tower', tower?.name ?? flat.towerId),
            const SizedBox(height: 12),
            _buildInfoRow('Floor', floor?.displayName ?? 'Floor ${flat.floorId}'),
            const SizedBox(height: 12),
            _buildInfoRow('Registered', Formatters.formatDate(flat.createdAt)),
          ],
        ),
      ),
      actions: [
        AppButton(
          text: 'Close',
          variant: AppButtonVariant.outlined,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildDetailTile(BuildContext context, String title, Widget trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
