import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_restaurapp/models/employee_model.dart';
import 'package:logging/logging.dart';

class EmployeeService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createEmployee(Employee employee) async {
    try {
      DocumentReference docRef = await _firestore.collection('employees').add({
        'firstName': employee.firstName,
        'lastName': employee.lastName,
        'identification': employee.identification,
        'email': employee.email,
        'profilePicture': employee.profilePicture,
        'position': employee.position,
        'isManager': employee.isManager,
      });
      employee.identification = docRef.id;

      updateEmployee(employee);
    } catch (e) {
      Logger('logger').severe(e);
      rethrow;
    }
  }

  Future<List<Employee>> getEmployees() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('employees').get();
      List<Employee> employees = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Employee(
          id: doc.id, // Use document ID
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          identification: data['identification'] ?? '',
          email: data['email'] ?? '',
          profilePicture: data['profilePicture'] ?? '',
          position: data['position'] ?? '',
          isManager: data['isManager'] ?? false,
        );
      }).toList();
      return employees;
    } catch (e) {
      Logger('logger').severe(e);
      rethrow;
    }
  }

  Stream<List<Employee>> getEmployeesStream() {
    return _firestore.collection('employees').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Employee(
          id: doc.id,
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          identification: data['identification'] ?? '',
          email: data['email'] ?? '',
          profilePicture: data['profilePicture'] ?? '',
          position: data['position'] ?? '',
          isManager: data['isManager'] ?? false,
        );
      }).toList();
    });
  }

  Future<Employee> getEmployee(String id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('employees').doc(id).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return Employee(
          id: documentSnapshot.id, // Use document ID
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          identification: data['identification'] ?? '',
          email: data['email'] ?? '',
          profilePicture: data['profilePicture'] ?? '',
          position: data['position'] ?? '',
          isManager: data['isManager'] ?? false,
        );
      } else {
        throw Exception('Employee not found');
      }
    } catch (e) {
      Logger('logger').severe(e);
      rethrow;
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      await _firestore.collection('employees').doc(employee.id).update({
        'firstName': employee.firstName,
        'lastName': employee.lastName,
        'identification': employee.identification,
        'email': employee.email,
        'profilePicture': employee.profilePicture,
        'position': employee.position,
        'isManager': employee.isManager,
      });
    } catch (e) {
      Logger('Logger').severe(e);
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    try {
      await _firestore.collection('employees').doc(employeeId).delete();
    } catch (e) {
      Logger('Logger').severe(e);
    }
  }

  Future<Map<String, int>> getEmployeeCountsByPosition() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('employees').get();
      List<Employee> employees = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Employee(
          id: doc.id, // Use document ID
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          identification: data['identification'] ?? '',
          email: data['email'] ?? '',
          profilePicture: data['profilePicture'] ?? '',
          position: data['position'] ?? '',
          isManager: data['isManager'] ?? false,
        );
      }).toList();

      Map<String, int> positionCounts = {};
      for (var employee in employees) {
        positionCounts[employee.position] =
            (positionCounts[employee.position] ?? 0) + 1;
      }

      return positionCounts;
    } catch (e) {
      Logger('logger').severe(e);
      rethrow;
    }
  }
}
