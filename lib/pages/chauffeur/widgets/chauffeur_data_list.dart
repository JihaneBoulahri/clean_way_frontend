import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chauffeur_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class ChauffeurDataList extends StatelessWidget {
  final List<Chauffeur> chauffeurs;

  const ChauffeurDataList({
    super.key,
    required this.chauffeurs,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: DataTable(
              showCheckboxColumn: false,
              headingRowHeight: 52,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 66,
              horizontalMargin: isNarrow ? 8 : 12,
              columnSpacing: isNarrow ? 8 : 16,
              headingRowColor: MaterialStatePropertyAll(
                scheme.primary.withValues(alpha: 0.08),
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'Chauffeur',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'CNI',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Camion',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
              rows: List.generate(chauffeurs.length, (index) {
                final chauffeur = chauffeurs[index];
                final rowColor = index.isEven
                    ? scheme.surface
                    : scheme.primary.withValues(alpha: 0.03);

                return DataRow.byIndex(
                  index: index,
                  color: MaterialStatePropertyAll(rowColor),
                  onSelectChanged: (_) {
                    Get.toNamed(AppRoutes.chauffeurDetail, arguments: chauffeur);
                  },
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            chauffeur.user?.fullName ?? 'Chauffeur #${chauffeur.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        chauffeur.cni,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        chauffeur.camion?.immatriculation ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
