import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/portfolio_data.dart';
import '../models/portfolio_validation.dart';
import 'profile_view_tracker.dart';

class PortfolioService {
  final FirebaseFirestore? _injectedFirestore;
  final FirebaseAuth? _injectedAuth;
  final DateTime Function() _clock;
  final ProfileViewTracker _viewTracker;

  PortfolioService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    DateTime Function()? clock,
    Future<void> Function(String slug)? recordProfileView,
  }) : _injectedFirestore = firestore,
       _injectedAuth = auth,
       _clock = clock ?? DateTime.now,
       _viewTracker = ProfileViewTracker(recordProfileView);

  FirebaseFirestore get _firestore =>
      _injectedFirestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;

  static const String _settingsDoc = 'settings/main';
  static const String _projectsCollection = 'projects';
  static const String _experienceCollection = 'experience';
  static const String _jobsCollection = 'jobs';
  static const String _profilesCollection = 'publicProfiles';
  static const String _slugsCollection = 'profileSlugs';

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  Stream<User?> get authStateChanges => _auth.idTokenChanges();

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  Future<void> signOut() => _auth.signOut();

  Future<PortfolioSettings> getSettings() async {
    final doc = await _firestore.doc(_settingsDoc).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('The portfolio has not been published yet.');
    }
    return PortfolioSettings.fromMap(doc.data()!);
  }

  Stream<PortfolioSettings> watchSettings() => _firestore
      .doc(_settingsDoc)
      .snapshots()
      .map(
        (doc) => doc.data() == null
            ? PortfolioSettings.empty()
            : PortfolioSettings.fromMap(doc.data()!),
      );

  Future<void> updateSettings(PortfolioSettings settings) async {
    validateSettings(settings);
    await _firestore.doc(_settingsDoc).set(settings.toMap());
  }

  Future<List<Project>> getAllProjects() async {
    final snapshot = await _firestore
        .collection(_projectsCollection)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => Project.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Project>> watchProjects() => _firestore
      .collection(_projectsCollection)
      .orderBy('order')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Project.fromMap(doc.data(), doc.id))
            .toList(),
      );

  Future<List<Project>> getActiveProjects() async {
    final snapshot = await _firestore
        .collection(_projectsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => Project.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _activeDocumentsByIds(
    String collection,
    List<String> ids,
  ) async {
    final unique = ids
        .where((id) => RegExp(r'^[a-zA-Z0-9_-]{1,128}$').hasMatch(id))
        .toSet()
        .toList();
    final result = <DocumentSnapshot<Map<String, dynamic>>>[];
    // A mixed-active document-ID IN query can be denied as a whole. Retrieve
    // known IDs in bounded parallel groups instead, omitting each inaccessible
    // archived/deleted item while preserving selection order. This also avoids
    // the Standard edition disjunction limit for selections longer than 30.
    Future<DocumentSnapshot<Map<String, dynamic>>?> read(String id) async {
      try {
        final doc = await _firestore.collection(collection).doc(id).get();
        return doc.data()?['isActive'] == true ? doc : null;
      } on FirebaseException catch (error) {
        if (error.code == 'permission-denied' || error.code == 'not-found') {
          return null;
        }
        rethrow;
      }
    }

    for (var start = 0; start < unique.length; start += 30) {
      final end = (start + 30 < unique.length) ? start + 30 : unique.length;
      final docs = await Future.wait(unique.sublist(start, end).map(read));
      result.addAll(docs.whereType<DocumentSnapshot<Map<String, dynamic>>>());
    }
    return result;
  }

  Future<List<Project>> getProjectsByIds(List<String> ids) async =>
      (await _activeDocumentsByIds(
        _projectsCollection,
        ids,
      )).map((doc) => Project.fromMap(doc.data()!, doc.id)).toList();

  Map<String, dynamic> _createData(Map<String, dynamic> fields) => {
    ...fields,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> _updateData(Map<String, dynamic> fields) => {
    for (final entry in fields.entries)
      if (entry.key != 'createdAt' &&
          entry.key != 'updatedAt' &&
          entry.key != 'viewCount')
        entry.key: entry.value,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Future<String> addProject(Project project) async {
    validateProject(project);
    return (await _firestore
            .collection(_projectsCollection)
            .add(_createData(project.toMap())))
        .id;
  }

  Future<void> updateProject(Project project) async {
    validateProject(project);
    await _firestore
        .collection(_projectsCollection)
        .doc(project.id)
        .update(_updateData(project.toMap()));
  }

  // Archiving preserves default/job references and permits restoring the item.
  // Public queries and rules both exclude archived content.
  Future<void> deleteProject(String id) => _archive(_projectsCollection, id);

  Future<void> _archive(String collection, String id) => _firestore
      .collection(collection)
      .doc(id)
      .update({'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});

  Future<List<Experience>> getAllExperience() async {
    final snapshot = await _firestore
        .collection(_experienceCollection)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => Experience.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Experience>> watchExperience() => _firestore
      .collection(_experienceCollection)
      .orderBy('order')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Experience.fromMap(doc.data(), doc.id))
            .toList(),
      );

  Future<List<Experience>> getActiveExperience() async {
    final snapshot = await _firestore
        .collection(_experienceCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => Experience.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Experience>> getExperienceByIds(List<String> ids) async =>
      (await _activeDocumentsByIds(
        _experienceCollection,
        ids,
      )).map((doc) => Experience.fromMap(doc.data()!, doc.id)).toList();

  Future<String> addExperience(Experience experience) async {
    validateExperience(experience);
    return (await _firestore
            .collection(_experienceCollection)
            .add(_createData(experience.toMap())))
        .id;
  }

  Future<void> updateExperience(Experience experience) async {
    validateExperience(experience);
    await _firestore
        .collection(_experienceCollection)
        .doc(experience.id)
        .update(_updateData(experience.toMap()));
  }

  Future<void> deleteExperience(String id) =>
      _archive(_experienceCollection, id);

  Future<List<JobPosting>> getAllJobs() async {
    final snapshot = await _firestore
        .collection(_jobsCollection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => JobPosting.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<JobPosting>> watchJobs() => _firestore
      .collection(_jobsCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => JobPosting.fromMap(doc.data(), doc.id))
            .toList(),
      );

  Future<JobPosting?> getJobBySlug(String slug) async {
    if (!RegExp(r'^[a-z0-9][a-z0-9-]{0,99}$').hasMatch(slug)) return null;
    try {
      // Public visitors never read the private jobs collection or enumerate profiles.
      final doc = await _firestore
          .collection(_profilesCollection)
          .doc(slug)
          .get();
      final data = doc.data();
      if (data == null) return null;
      final profile = JobPosting.fromPublicMap(data, slug);
      if (!profile.isActive ||
          (profile.expiresAt != null &&
              !profile.expiresAt!.isAfter(_clock()))) {
        return null;
      }
      return profile;
    } on FirebaseException catch (error) {
      // Inactive/expired documents are deliberately indistinguishable from
      // unavailable links. Network and decoding failures still reach the UI.
      if (error.code == 'permission-denied' || error.code == 'not-found') {
        return null;
      }
      rethrow;
    }
  }

  Future<bool> isSlugAvailable(String slug, {String? excludeId}) async {
    if (!RegExp(r'^[a-z0-9][a-z0-9-]{0,99}$').hasMatch(slug)) return false;
    final reservation = await _firestore
        .collection(_slugsCollection)
        .doc(slug)
        .get();
    if (reservation.exists) {
      return excludeId != null && reservation.data()?['jobId'] == excludeId;
    }
    // Helps identify legacy conflicts before migration. Transactions below are
    // authoritative once all old jobs have been migrated to reservations.
    final legacy = await _firestore
        .collection(_jobsCollection)
        .where('slug', isEqualTo: slug)
        .get();
    return legacy.docs.every((doc) => doc.id == excludeId);
  }

  Future<String> addJob(JobPosting job) async {
    validateJob(job);
    final jobRef = _firestore.collection(_jobsCollection).doc();
    final slugRef = _firestore.collection(_slugsCollection).doc(job.slug);
    final publicRef = _firestore.collection(_profilesCollection).doc(job.slug);
    await _firestore.runTransaction((transaction) async {
      final reservation = await transaction.get(slugRef);
      if (reservation.exists) throw StateError('That slug is already in use.');
      transaction.set(jobRef, _createData(job.toMap())..['viewCount'] = 0);
      transaction.set(slugRef, {'jobId': jobRef.id});
      transaction.set(publicRef, _createData(job.toPublicMap()));
    });
    return jobRef.id;
  }

  Future<void> updateJob(JobPosting job) async {
    validateJob(job);
    final jobRef = _firestore.collection(_jobsCollection).doc(job.id);
    final newSlugRef = _firestore.collection(_slugsCollection).doc(job.slug);
    await _firestore.runTransaction((transaction) async {
      final current = await transaction.get(jobRef);
      if (!current.exists) throw StateError('This job no longer exists.');
      final previous = JobPosting.fromMap(current.data()!, current.id);
      final reservation = await transaction.get(newSlugRef);
      if (reservation.exists && reservation.data()?['jobId'] != job.id) {
        throw StateError('That slug is already in use.');
      }
      final oldSlugRef = _firestore
          .collection(_slugsCollection)
          .doc(previous.slug);
      final oldReservation = previous.slug != job.slug
          ? await transaction.get(oldSlugRef)
          : reservation;
      if (oldReservation.exists && oldReservation.data()?['jobId'] != job.id) {
        throw StateError(
          'This legacy slug conflicts with another job. Run the profile migration.',
        );
      }
      transaction.update(jobRef, _updateData(job.toMap()));
      transaction.set(newSlugRef, {'jobId': job.id});
      transaction
          .set(_firestore.collection(_profilesCollection).doc(job.slug), {
            ...job.toPublicMap(),
            'createdAt': current.data()!['createdAt'],
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (previous.slug != job.slug) {
        transaction.delete(oldSlugRef);
        transaction.delete(
          _firestore.collection(_profilesCollection).doc(previous.slug),
        );
      }
    });
  }

  Future<void> deleteJob(String id) async {
    final jobRef = _firestore.collection(_jobsCollection).doc(id);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(jobRef);
      if (!snapshot.exists) return;
      final job = JobPosting.fromMap(snapshot.data()!, id);
      final slugRef = _firestore.collection(_slugsCollection).doc(job.slug);
      final reservation = await transaction.get(slugRef);
      if (reservation.exists && reservation.data()?['jobId'] != id) {
        throw StateError(
          'This legacy slug conflicts with another job. Run the profile migration.',
        );
      }
      transaction.delete(jobRef);
      transaction.delete(slugRef);
      transaction.delete(
        _firestore.collection(_profilesCollection).doc(job.slug),
      );
    });
  }

  Future<PortfolioViewData> getPortfolioViewData(String? jobSlug) async {
    final settings = await getSettings();
    final job = jobSlug == null || jobSlug.isEmpty
        ? null
        : await getJobBySlug(jobSlug);
    final projectFuture = job != null
        ? getProjectsByIds(job.projectIds)
        : settings.defaultProjectIds.isEmpty
        ? getActiveProjects()
        : getProjectsByIds(settings.defaultProjectIds);
    final experienceFuture = job != null
        ? getExperienceByIds(job.experienceIds)
        : settings.defaultExperienceIds.isEmpty
        ? getActiveExperience()
        : getExperienceByIds(settings.defaultExperienceIds);
    final values = await Future.wait<Object>([projectFuture, experienceFuture]);
    if (job != null) unawaited(_viewTracker.record(job.slug));
    return PortfolioViewData(
      settings: settings,
      projects: values[0] as List<Project>,
      experiences: values[1] as List<Experience>,
      jobPosting: job,
    );
  }
}
