import 'package:flutter/material.dart';

class ActivityTile extends StatelessWidget {
  final String id;
  final String percent;
  final String status;
  final Color color;

  const ActivityTile({
    super.key,
    required this.id,
    required this.percent,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                id,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(color: color),
              ),
            ],
          ),
          Text(
            percent,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ],
      ),
    );
  }
}