import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class TimeRecordsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getTimeLogs() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No user is currently signed in.',
        );
      }

      String userIdentification =
          (await _firestore.collection('employees').doc(currentUser.uid).get())
              .data()?['identification'];

      QuerySnapshot querySnapshot = await _firestore
          .collection('timeRecords')
          .doc(userIdentification)
          .collection('logs')
          .get();

      List<Map<String, dynamic>> timeLogs = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
      return timeLogs;
    } catch (e) {
      Logger('logger').severe(e);
      rethrow;
    }
  }
}
