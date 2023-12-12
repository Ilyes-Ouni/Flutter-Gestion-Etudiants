// details_absence_screen.dart
import 'package:flutter/material.dart';
import '../entities/student.dart';
import '../entities/absence.dart';

class DetailsAbsenceScreen extends StatelessWidget {
  final Student student;
  final List<Absence> absences;

  DetailsAbsenceScreen({required this.student, required this.absences});

  @override
  Widget build(BuildContext context) {
    // Create a map to group absences by matiere
    Map<String, List<Absence>> absencesByMatiere = {};

    // Populate the map
    for (Absence absence in absences) {
      String matiereCode = absence.codeMatiere;
      if (!absencesByMatiere.containsKey(matiereCode)) {
        absencesByMatiere[matiereCode] = [];
      }
      absencesByMatiere[matiereCode]!.add(absence);
    }

    // Calculate overall total NHA
    int overallTotalNHA = absences.fold(0, (sum, absence) => sum + absence.nha);

    return Scaffold(
      appBar: AppBar(
        title: Text('Details des absences'),
        backgroundColor: Color(0xFF7321CA),
      ),
      body: Column(
        children: [
          DataTable(
            columns: const [
              DataColumn(label: Text('Matière')),
              DataColumn(label: Text('Total NHA')),
            ],
            rows: absencesByMatiere.entries.map((entry) {
              String matiereCode = entry.key;
              List<Absence> absencesForMatiere = entry.value;

              // Calculate total NHA for the matiere
              int totalNHA = absencesForMatiere.fold(0, (sum, absence) => sum + absence.nha);

              return DataRow(
                cells: [
                  DataCell(Text(matiereCode)),
                  DataCell(Text(totalNHA.toString())),
                ],
              );
            }).toList(),
          ),
          // Display overall total NHA at the bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Overall Total NHA: $overallTotalNHA'),
          ),
        ],
      ),
    );
  }
}
