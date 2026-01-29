import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/blueprint_model.dart';

class CourseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveCourse(String userId, CourseModel course) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(course.id)
        .set(course.toMap());
  }

  Future<void> saveBlueprint(String userId, BlueprintModel blueprint) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('blueprints')
        .doc(blueprint.id)
        .set(blueprint.toMap());
  }

  Future<List<CourseModel>> getCourses(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
        .toList()
        .cast<CourseModel>();
  }

  Future<List<BlueprintModel>> getBlueprints(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('blueprints')
        .orderBy('uploadedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BlueprintModel.fromMap(doc.data(), doc.id))
        .toList()
        .cast<BlueprintModel>();
  }
}
