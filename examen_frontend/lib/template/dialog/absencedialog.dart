import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../entities/absence.dart';
import '../../entities/matiere.dart';
import '../../entities/student.dart';
import '../../service/absence_service.dart';

class AbsenceDialog extends StatelessWidget {
  final AbsenceService _absenceService = AbsenceService();

  Future<void> showAddAbsenceDialog(BuildContext context, Student selectedStudent) async {
    Matiere? _selectedMatiere;
    DateTime _selectedDate = DateTime.now();
    TextEditingController _nhaController = TextEditingController();

    List<Matiere> matieres =
    await _absenceService.fetchMatieresForClass(selectedStudent.classe!.codClass?.toString() ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une absence'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                DropdownButtonFormField<Matiere>(
                  value: _selectedMatiere,
                  onChanged: (newValue) {
                    _selectedMatiere = newValue!;
                  },
                  items: matieres.map<DropdownMenuItem<Matiere>>((Matiere matiere) {
                    return DropdownMenuItem<Matiere>(
                      value: matiere,
                      child: Text(matiere.nom!),
                    );
                  }).toList(),
                ),
                ListTile(
                  title: Text("Date d'absence: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2025),
                    );
                    if (picked != null && picked != _selectedDate) {
                      _selectedDate = picked;
                    }
                  },
                ),
                TextField(
                  controller: _nhaController,
                  decoration: InputDecoration(labelText: 'Nombre d\'heures d\'absence (NHA)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                _addAbsence(
                  selectedStudent.id!,
                  _selectedMatiere!.code!,
                  _selectedDate,
                  int.parse(_nhaController.text),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addAbsence(int studentId, int matiereId, DateTime date, int nha) async {
    try {
      await _absenceService.addAbsence(studentId, matiereId, date, nha);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
