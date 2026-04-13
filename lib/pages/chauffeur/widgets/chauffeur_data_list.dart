import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chauffeur_model.dart';
import '../../../routes/app_routes.dart';

class ChauffeurDataList extends StatelessWidget {
  final List<Chauffeur> chauffeurs;

  const ChauffeurDataList({super.key, required this.chauffeurs});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final headingSize = isNarrow ? 12.0 : 14.0;
        final bodySize = isNarrow ? 11.0 : 13.0;
        final rowMinHeight = isNarrow ? 50.0 : 60.0;
        final rowMaxHeight = isNarrow ? 56.0 : 66.0;
        final iconBox = isNarrow ? 24.0 : 30.0;
        final iconSize = isNarrow ? 14.0 : 16.0;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: isNarrow ? 44 : 52,
                  dataRowMinHeight: rowMinHeight,
                  dataRowMaxHeight: rowMaxHeight,
                  horizontalMargin: isNarrow ? 6 : 12,
                  columnSpacing: isNarrow ? 6 : 16,
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
                          fontSize: headingSize,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CNI',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                          fontSize: headingSize,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Camion',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                          fontSize: headingSize,
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
                        Get.toNamed(
                          AppRoutes.chauffeurDetail,
                          arguments: chauffeur,
                        );
                      },
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              Container(
                                width: iconBox,
                                height: iconBox,
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: iconSize,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                chauffeur.user?.fullName ??
                                    (chauffeur.userId != null
                                        ? 'Utilisateur #${chauffeur.userId}'
                                        : 'Chauffeur #${chauffeur.id}'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: bodySize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            chauffeur.cni.trim().isEmpty
                                ? 'Non renseigne'
                                : chauffeur.cni,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.85),
                              fontSize: bodySize,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            chauffeur.camion?.immatriculation ??
                                (chauffeur.camionId != null
                                    ? 'Camion #${chauffeur.camionId}'
                                    : '-'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.85),
                              fontSize: bodySize,
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
