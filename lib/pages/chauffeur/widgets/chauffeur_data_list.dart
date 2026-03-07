import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/chauffeur_model.dart';
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
        final tableWidth = constraints.maxWidth > 620 ? constraints.maxWidth : 620.0;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 52,
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 66,
                  horizontalMargin: isNarrow ? AppSpacing.sm : AppSpacing.md,
                  columnSpacing: isNarrow ? AppSpacing.md : AppSpacing.xl,
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
                    DataColumn(
                      label: Text(
                        'Num tele',
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
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            chauffeur.cni,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            chauffeur.camion?.immatriculation ?? '-',
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            chauffeur.numTelephone,
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
            ),
          ),
        );
      },
    );
  }
}
