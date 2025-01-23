// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_restaurapp/models/employee_model.dart';
import 'package:flutter_restaurapp/services/employee_service.dart';
import 'package:flutter_restaurapp/services/firebase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EmployeeDetailPage extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailPage({super.key, required this.employee});

  @override
  _EmployeeDetailPageState createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _positionController;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isDirty = false;
  String? _selectedPosition;

  Future<void> _selectFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _isDirty = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.employee.firstName);
    _lastNameController = TextEditingController(text: widget.employee.lastName);
    _positionController = TextEditingController(text: widget.employee.position);

    _firstNameController.addListener(_handleTextFieldChanges);
    _lastNameController.addListener(_handleTextFieldChanges);
    _positionController.addListener(_handleTextFieldChanges);

    _selectedPosition = widget.employee.position;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _handleTextFieldChanges() {
    setState(() {
      _isDirty = true;
    });
  }

  void _updateEmployeeDetails() async {
    try {
      String profilePictureUrl = '';

      if (_image != null) {
        profilePictureUrl = await FirebaseService().uploadImage(_image!);
      }

      Employee updatedEmployee = Employee(
        id: widget.employee.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        identification: widget.employee.identification,
        email: widget.employee.email,
        profilePicture: profilePictureUrl != ""
            ? profilePictureUrl
            : widget.employee.profilePicture,
        position: _positionController.text,
        isManager: widget.employee.isManager,
      );
      await EmployeeService().updateEmployee(updatedEmployee);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hubo un problema guardando los cambios.')),
      );
    }
    setState(() {
      _isDirty = false;
    });
    Navigator.pop(context);
  }

  void _showActions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              _showTimeRecordModal();
            },
            child: const Text('Registrar tiempo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              try {
                _deleteEmployee();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Empleado dado de baja exitosamente.')),
                );
                Navigator.pop(context); // Close action sheet
                Navigator.pop(context); // Pop EmployeeDetailPage
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Hubo un problema dando de baja al empleado.')),
                );
              }
            },
            isDestructiveAction: true,
            child: const Text('Dar de baja'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          isDefaultAction: true,
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  void _deleteEmployee() async {
    try {
      await FirebaseService().deleteUser(widget.employee.email);
      await EmployeeService().deleteEmployee(widget.employee.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empleado dado de baja exitosamente.'),
        ),
      );

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hubo un problema dando de baja al empleado.'),
        ),
      );
    }
  }

  Future<void> _showTimeRecordModal() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TimeRecordModal(
          employeeId: widget.employee.id,
          employeeIdentification: widget.employee.identification,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var positions = ["Cocinero", "Camarero", "Limpiador", "Contable"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar empleado"),
        actions: [
          TextButton(
            onPressed: _showActions,
            child: const Text(
              'Opciones',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: _selectFromGallery,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (widget.employee.profilePicture.isNotEmpty
                              ? NetworkImage(widget.employee.profilePicture)
                              : null) as ImageProvider?,
                      child: _image == null &&
                              widget.employee.profilePicture.isEmpty
                          ? const Icon(
                              Icons.camera_alt_rounded,
                              size: 70,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPosition = newValue;
                    _positionController.text = newValue ?? '';
                    _handleTextFieldChanges(); // Trigger dirty state
                  });
                },
                items: positions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Position',
                ),
              ),
              const SizedBox(height: 16),
              if (_isDirty)
                Center(
                  child: ElevatedButton(
                    onPressed: _updateEmployeeDetails,
                    child: const Text('Guardar cambios'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeRecordModal extends StatefulWidget {
  final String employeeId;
  final String employeeIdentification;

  const TimeRecordModal({
    super.key,
    required this.employeeId,
    required this.employeeIdentification,
  });

  @override
  _TimeRecordModalState createState() => _TimeRecordModalState();
}

class _TimeRecordModalState extends State<TimeRecordModal> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar Tiempo'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha'),
              subtitle: Text('${selectedDate.toLocal()}'.split(' ')[0]),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate:
                      DateTime.now(), // Ensure date is not tomorrow or later
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Hora inicio'),
              subtitle: Text(startTime.format(context)),
              onTap: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: startTime,
                );
                if (pickedTime != null && _isTimeValid(pickedTime)) {
                  setState(() {
                    startTime = pickedTime;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Hora fin'),
              subtitle: Text(endTime.format(context)),
              onTap: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: endTime,
                );
                if (pickedTime != null) {
                  setState(() {
                    endTime = pickedTime;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Registrar'),
          onPressed: () async {
            await _registerTimeRecord(selectedDate, startTime, endTime);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  bool _isTimeValid(TimeOfDay time) {
    if (time.hour < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La hora de inicio no puede ser antes de las 7 AM.')),
      );
      return false;
    }
    return true;
  }

  Future<void> _registerTimeRecord(
      DateTime date, TimeOfDay startTime, TimeOfDay endTime) async {
    try {
      DateTime startDateTime = DateTime(
          date.year, date.month, date.day, startTime.hour, startTime.minute);
      DateTime endDateTime = DateTime(
          date.year, date.month, date.day, endTime.hour, endTime.minute);

      String formattedDate = DateFormat('dd/MM/yyyy').format(date);
      String formattedStartTime = DateFormat('HH:mm').format(startDateTime);
      String formattedEndTime = DateFormat('HH:mm').format(endDateTime);

      await FirebaseFirestore.instance
          .collection('timeRecords')
          .doc(widget.employeeIdentification)
          .collection('logs')
          .add({
        'date': formattedDate,
        'startTime': formattedStartTime,
        'endTime': formattedEndTime,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registro de tiempo guardado exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hubo un problema guardando el registro de tiempo.')),
      );
    }
  }
}
