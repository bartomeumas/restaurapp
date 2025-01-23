// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurapp/models/employee_model.dart';
import 'package:flutter_restaurapp/pages/employee_detail_page.dart';
import 'package:flutter_restaurapp/services/employee_service.dart';
import 'package:flutter_restaurapp/services/firebase_service.dart';

class EmployeesPage extends StatelessWidget {
  final EmployeeService _employeeService = EmployeeService();
  final FirebaseService _firebaseService = FirebaseService();

  EmployeesPage({super.key});

  void _navigateToEmployeeDetail(BuildContext context,
      {required Employee employee}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailPage(employee: employee),
      ),
    );
  }

  Future<bool> _canNavigate(Employee employee) async {
    bool isAdmin = await _firebaseService.isUserAdmin();
    User? currentUser = _firebaseService.currentUser;
    return isAdmin || (currentUser != null && currentUser.uid == employee.id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Employee>>(
      stream: _employeeService.getEmployeesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final employees = snapshot.data!;

        return ListView.separated(
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final employee = employees[index];

            return ListTile(
              title: Text('${employee.firstName} ${employee.lastName}'),
              subtitle: Text(employee.position),
              leading: CircleAvatar(
                backgroundImage: employee.profilePicture.isNotEmpty
                    ? NetworkImage(employee.profilePicture)
                    : null,
                child: employee.profilePicture.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              onTap: () async {
                bool canNavigate = await _canNavigate(employee);
                if (canNavigate) {
                  _navigateToEmployeeDetail(context, employee: employee);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'No tienes permiso para ver los detalles de este empleado'),
                    ),
                  );
                }
              },
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
        );
      },
    );
  }
}
