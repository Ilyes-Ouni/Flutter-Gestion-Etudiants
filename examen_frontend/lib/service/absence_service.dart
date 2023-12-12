import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../entities/absence.dart';
import '../entities/matiere.dart';
import '../entities/student.dart';

class AbsenceService {
  Future<List<Student>> fetchStudents() async {
    var response = await http.get(Uri.parse('http://10.0.2.2:8081/etudiant/all'));
    if (response.statusCode == 200) {
      List<dynamic> studentsJson = json.decode(response.body);
      return studentsJson.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<List<Matiere>> fetchMatieresForClass(String id) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8081/matiere/findByClasseId/$id'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Matiere.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load matieres');
    }
  }

  Future<List<Absence>> fetchAbsences(int studentId) async {
    var response = await http.get(Uri.parse('http://10.0.2.2:8081/absences/getByStudent/$studentId'));
    if (response.statusCode == 200) {
      List<dynamic> absencesJson = json.decode(response.body);
      return absencesJson.map((json) => Absence.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load absences');
    }
  }

  Future<void> deleteAbsence(int absenceId) async {
    var response = await http.delete(Uri.parse('http://10.0.2.2:8081/absences/delete?id=$absenceId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete absence');
    }
  }

  Future<void> addAbsence(int studentId, int matiereId, DateTime date, int nha) async {
    var absenceData = {
      'etudiant': {'id': studentId},
      'matiere': {'code': matiereId},
      'date': DateFormat('yyyy-MM-dd').format(date),
      'nha': nha,
    };

    var response = await http.post(
      Uri.parse('http://10.0.2.2:8081/absences/add'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(absenceData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add absence');
    }
  }


  Future<void> updateAbsence(int absenceId, int nha) async {
    var absenceData = {
      'id': absenceId,
      'nha': nha,
    };

    var response = await http.put(
      Uri.parse('http://10.0.2.2:8081/absences/update'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(absenceData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update absence');
    }
  }
}
