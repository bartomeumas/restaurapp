// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TimeRecordsPage extends StatefulWidget {
  const TimeRecordsPage({super.key});

  @override
  _TimeRecordsPageState createState() => _TimeRecordsPageState();
}

class _TimeRecordsPageState extends State<TimeRecordsPage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  List<Map<String, dynamic>> _timeLogs = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchTimeLogs(_selectedDay);
  }

  Future<void> _fetchTimeLogs(DateTime day) async {
    setState(() {
      _loading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No hay usuario actualmente autenticado.',
        );
      }

      String userIdentification = (await FirebaseFirestore.instance
              .collection('employees')
              .doc(currentUser.uid)
              .get())
          .data()?['identification'];

      String formattedDate = DateFormat('dd/MM/yyyy').format(day);

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('timeRecords')
          .doc(userIdentification)
          .collection('logs')
          .where('date', isEqualTo: formattedDate)
          .get();

      List<Map<String, dynamic>> timeLogs = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      setState(() {
        _timeLogs = timeLogs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se pudo obtener los registros de tiempo.')),
      );
    }
  }

  void _showTimeRecordModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const TimeRecordModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _showTimeRecordModal,
                  child: const Text('Reportar horas'),
                ),
                TableCalendar(
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _fetchTimeLogs(selectedDay);
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _timeLogs.length,
                    itemBuilder: (context, index) {
                      var log = _timeLogs[index];
                      return ListTile(
                        title: Text('Fecha: ${log['date']}'),
                        subtitle: Text(
                            'Inicio: ${log['startTime']} - Fin: ${log['endTime']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TimeRecordModal extends StatefulWidget {
  const TimeRecordModal({super.key});

  @override
  _TimeRecordModalState createState() => _TimeRecordModalState();
}

class _TimeRecordModalState extends State<TimeRecordModal> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = TimeOfDay.now();
  bool _saving = false;

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
                  lastDate: DateTime.now(),
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
                if (pickedTime != null) {
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
          child: _saving
              ? const CircularProgressIndicator()
              : const Text('Registrar'),
          onPressed: () async {
            setState(() {
              _saving = true;
            });
            await _registerTimeRecord();
            setState(() {
              _saving = false;
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<void> _registerTimeRecord() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No hay usuario actualmente autenticado.',
        );
      }

      String userIdentification = (await FirebaseFirestore.instance
              .collection('employees')
              .doc(currentUser.uid)
              .get())
          .data()?['identification'];

      DateTime startDateTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, startTime.hour, startTime.minute);
      DateTime endDateTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, endTime.hour, endTime.minute);

      String formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
      String formattedStartTime = DateFormat('HH:mm').format(startDateTime);
      String formattedEndTime = DateFormat('HH:mm').format(endDateTime);

      await FirebaseFirestore.instance
          .collection('timeRecords')
          .doc(userIdentification)
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
