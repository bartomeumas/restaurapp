// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_restaurapp/models/employee_model.dart';
import 'package:flutter_restaurapp/services/firebase_service.dart';
import 'package:image_picker/image_picker.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _identificationController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedPosition;

  File? _profileImage;

  final _formKey = GlobalKey<FormState>();

  FirebaseService firebaseService = FirebaseService();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      String firstName = _firstNameController.text;
      String lastName = _lastNameController.text;
      String identification = _identificationController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String position = _selectedPosition ?? '';

      try {
        String profilePictureUrl = '';

        if (_profileImage != null) {
          profilePictureUrl =
              await FirebaseService().uploadImage(_profileImage!);
        }

        var newEmployee = Employee(
          id: email,
          firstName: firstName,
          lastName: lastName,
          identification: identification,
          email: email,
          profilePicture: profilePictureUrl,
          position: position,
          isManager: false,
        );

        await firebaseService.signUpUser(newEmployee, password);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$firstName registrado correctamente')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fallo en el registro: $e')),
        );
      }
    }
  }

  Future<void> _selectProfilePicture() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var positions = ["Cocinero", "Camarero", "Limpiador", "Contable"];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Empleado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Introduzca su nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  hintText: 'Introduzca sus apellidos',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese sus apellidos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _identificationController,
                decoration: const InputDecoration(
                  labelText: 'DNI/NIF',
                  hintText: 'Introduzca su DNI/NIF',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su DNI/NIF';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'Introduzca su correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Introduzca su contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la contraseña';
                  } else if (value != _confirmPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  hintText: 'Repita la contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor repita la contraseña';
                  } else if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPosition = newValue;
                  });
                },
                items: positions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione un rol';
                  }
                  return null;
                },
              ),
              GestureDetector(
                onTap: _selectProfilePicture,
                child: Center(
                  child: _profileImage == null
                      ? const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey,
                        )
                      : CircleAvatar(
                          radius: 40,
                          backgroundImage: FileImage(_profileImage!),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _registerUser();
                  }
                },
                child: const Text('Crear cuenta'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
