import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './DetailsAbsenceScreen.dart';
import '../entities/absence.dart';
import '../entities/matiere.dart';
import '../entities/student.dart';
import '../service/absence_service.dart';

class AbsenceScreen extends StatefulWidget {
  @override
  _AbsenceScreenState createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Student> students = [];
  Absence? _selectedAbsence;
  Student? _selectedStudent;
  List<Absence> absences = [];
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _classeController = TextEditingController();
  final AbsenceService _absenceService = AbsenceService();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      List<Student> fetchedStudents = await _absenceService.fetchStudents();
      setState(() {
        students = fetchedStudents;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _updateStudentInfo(Student student) {
    _nomController.text = student.nom;
    _prenomController.text = student.prenom;
    _classeController.text = student.classe!.nomClass;
    if (student.id != null) {
      _fetchAbsences(student.id!);
    }
  }

  Future<void> _fetchAbsences(int studentId) async {
    try {
      List<Absence> fetchedAbsences = await _absenceService.fetchAbsences(studentId);
      setState(() {
        absences = fetchedAbsences;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _deleteAbsence(Absence absence) async {
    try {
      await _absenceService.deleteAbsence(absence.id!);
      setState(() {
        absences.removeWhere((a) => a.id == absence.id);
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _addAbsence(int studentId, int matiereId, DateTime date, int nha) async {
    try {
      await _absenceService.addAbsence(studentId, matiereId, date, nha);
      _fetchAbsences(studentId);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _showAddAbsenceDialog() async {
    Matiere? _selectedMatiere;
    DateTime _selectedDate = DateTime.now();
    TextEditingController _nhaController = TextEditingController();

    List<Matiere> matieres =
    await _absenceService.fetchMatieresForClass(_selectedStudent!.classe!.codClass?.toString() ?? '');

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
                    setState(() {
                      _selectedMatiere = newValue!;
                    });
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
                      setState(() {
                        _selectedDate = picked;
                      });
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
                  _selectedStudent!.id!,
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

  DataRow _buildRow(Absence absence) {
    return DataRow(
      cells: [
        DataCell(
          Text(absence.date),
          onTap: () {
            // Perform the action when tapping on a cell
            _selectedAbsence = absence;
            _deleteAbsence(_selectedAbsence!); // or any other action you want
          },
        ),
        DataCell(Text(absence.codeMatiere)),
        DataCell(Text(absence.nha.toString())),
      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saisie des absences pour un étudiant'),
        backgroundColor: Color(0xFF7321CA),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            DropdownButtonFormField<Student>(
              value: _selectedStudent,
              hint: Text('Sélectionner un étudiant'),
              onChanged: (newValue) {
                setState(() {
                  _selectedStudent = newValue!;
                  _updateStudentInfo(_selectedStudent!);
                });
              },
              items: students.map<DropdownMenuItem<Student>>((Student student) {
                return DropdownMenuItem<Student>(
                  value: student,
                  child: Text('${student.nom} ${student.prenom}'),
                );
              }).toList(),
            ),
            TextFormField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom de l\'étudiant:'),
              readOnly: true,
            ),
            TextFormField(
              controller: _prenomController,
              decoration: InputDecoration(labelText: 'Prénom:'),
              readOnly: true,
            ),
            TextFormField(
              controller: _classeController,
              decoration: InputDecoration(labelText: 'Classe:'),
              readOnly: true,
            ),
            SizedBox(height: 20),
            Text('Liste des absences'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Date d'absence")),
                  DataColumn(label: Text('Matière')),
                  DataColumn(label: Text("Nbr d'heures")),
                ],
                rows: absences.map((absence) => _buildRow(absence)).toList(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF7321CA),
                  ),
                  child: Text('Insérer'),
                  onPressed: () {
                    if (_selectedStudent != null) {
                      _showAddAbsenceDialog();
                    } else {
                      // Inform the user to select a student first
                    }
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF7321CA),
                  ),
                  child: Text('Supprimer'),
                  onPressed: () {
                    if (_selectedAbsence != null) {
                      _deleteAbsence(_selectedAbsence!);
                    } else {
                      print("No absence selected");
                    }
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF7321CA),
                  ),
                  child: Text('Modifier'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Validate action
                    }
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF7321CA), // Set the background color
                  ),
                  child: Text('Détails'),
                  onPressed: () {
                    if (_selectedStudent != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailsAbsenceScreen(
                            student: _selectedStudent!,
                            absences: absences,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}