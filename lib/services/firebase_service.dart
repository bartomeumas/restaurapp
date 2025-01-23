import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_restaurapp/models/employee_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseAuth get auth => _auth;

  Future<void> signUpUser(Employee employee, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: employee.email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('employees').doc(uid).set({
        'id': uid,
        'firstName': employee.firstName,
        'lastName': employee.lastName,
        'identification': employee.identification,
        'email': employee.email,
        'profilePicture': employee.profilePicture,
        'position': employee.position,
        'isManager': employee.isManager,
      });

      Logger('logger').info('Employee created successfully');
    } on FirebaseAuthException catch (e) {
      Logger('logger').severe(e);
      throw Exception('Failed to sign up user: $e');
    } catch (e) {
      Logger('logger').severe(e);
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger('Logger').info(userCredential);
    } on FirebaseAuthException catch (e) {
      Logger('logger').severe(e);
      throw Exception('Failed to sign in user: $e');
    } catch (e) {
      Logger('logger').severe(e);
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> signOutUser() async {
    try {
      Logger('logger')
          .info('Current user before sign out: ${_auth.currentUser}');
      await _auth.signOut();
      Logger('logger')
          .info('Current user after sign out: ${_auth.currentUser}');
      Logger('logger').info('User signed out successfully');
    } catch (e) {
      Logger('logger').severe('Error signing out: $e');
      throw Exception('Failed to sign out user: $e');
    }
  }

  Future<XFile?> compressImage(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 50,
    );
    return result;
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Directory tempDir = await getTemporaryDirectory();
      String targetPath = path.join(tempDir.path, '${fileName}_compressed.jpg');

      XFile? compressedFile = await compressImage(imageFile, targetPath);

      if (compressedFile == null) {
        throw Exception('Image compression failed');
      }

      Reference ref = _storage.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(File(compressedFile.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('employees')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.size > 0) {
        String userId = querySnapshot.docs.first.id;
        await _firestore.collection('employees').doc(userId).delete();
      }

      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      } else {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found in authentication.',
        );
      }

      Logger('logger').info('User deleted successfully');
    } on FirebaseAuthException catch (e) {
      Logger('logger').severe(e);
      throw Exception('Failed to delete user: $e');
    } catch (e) {
      Logger('logger').severe(e);
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> isUserAdmin() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      DocumentSnapshot documentSnapshot =
          await _firestore.collection('employees').doc(currentUser.uid).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return data['isManager'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      Logger('logger').severe(e);
      throw Exception('Failed to check admin status: $e');
    }
  }

  User? get currentUser => _auth.currentUser;
}
