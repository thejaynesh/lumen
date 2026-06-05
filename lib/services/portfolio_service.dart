import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/portfolio_data.dart';

class PortfolioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection paths
  static const String _settingsDoc = 'settings/main';
  static const String _projectsCollection = 'projects';
  static const String _experienceCollection = 'experience';
  static const String _jobsCollection = 'jobs';

  // ============== AUTH ==============

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ============== SETTINGS ==============

  Future<PortfolioSettings> getSettings() async {
    final doc = await _firestore.doc(_settingsDoc).get();
    if (doc.exists && doc.data() != null) {
      return PortfolioSettings.fromMap(doc.data()!);
    }
    return PortfolioSettings.empty();
  }

  Stream<PortfolioSettings> watchSettings() {
    return _firestore.doc(_settingsDoc).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return PortfolioSettings.fromMap(doc.data()!);
      }
      return PortfolioSettings.empty();
    });
  }

  Future<void> updateSettings(PortfolioSettings settings) async {
    await _firestore.doc(_settingsDoc).set(settings.toMap());
  }

  // ============== PROJECTS ==============

  Future<List<Project>> getAllProjects() async {
    final snapshot = await _firestore
        .collection(_projectsCollection)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => Project.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Project>> watchProjects() {
    return _firestore
        .collection(_projectsCollection)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Project.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

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

  Future<List<Project>> getProjectsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshot = await _firestore
        .collection(_projectsCollection)
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    // Sort by the order in ids list
    final projects = snapshot.docs
        .map((doc) => Project.fromMap(doc.data(), doc.id))
        .toList();
    projects.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
    return projects;
  }

  Future<String> addProject(Project project) async {
    final doc = await _firestore
        .collection(_projectsCollection)
        .add(project.toMap());
    return doc.id;
  }

  Future<void> updateProject(Project project) async {
    await _firestore
        .collection(_projectsCollection)
        .doc(project.id)
        .update(project.toMap());
  }

  Future<void> deleteProject(String id) async {
    await _firestore.collection(_projectsCollection).doc(id).delete();
  }

  // ============== EXPERIENCE ==============

  Future<List<Experience>> getAllExperience() async {
    final snapshot = await _firestore
        .collection(_experienceCollection)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => Experience.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Experience>> watchExperience() {
    return _firestore
        .collection(_experienceCollection)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Experience.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

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

  Future<List<Experience>> getExperienceByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshot = await _firestore
        .collection(_experienceCollection)
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    final experiences = snapshot.docs
        .map((doc) => Experience.fromMap(doc.data(), doc.id))
        .toList();
    experiences.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
    return experiences;
  }

  Future<String> addExperience(Experience experience) async {
    final doc = await _firestore
        .collection(_experienceCollection)
        .add(experience.toMap());
    return doc.id;
  }

  Future<void> updateExperience(Experience experience) async {
    await _firestore
        .collection(_experienceCollection)
        .doc(experience.id)
        .update(experience.toMap());
  }

  Future<void> deleteExperience(String id) async {
    await _firestore.collection(_experienceCollection).doc(id).delete();
  }

  // ============== JOBS ==============

  Future<List<JobPosting>> getAllJobs() async {
    final snapshot = await _firestore
        .collection(_jobsCollection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => JobPosting.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<JobPosting>> watchJobs() {
    return _firestore
        .collection(_jobsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JobPosting.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<JobPosting?> getJobBySlug(String slug) async {
    final snapshot = await _firestore
        .collection(_jobsCollection)
        .where('slug', isEqualTo: slug)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final job = JobPosting.fromMap(doc.data(), doc.id);

    if (job.expiresAt != null && job.expiresAt!.isBefore(DateTime.now())) {
      return null;
    }

    return job;
  }

  Future<bool> isSlugAvailable(String slug, {String? excludeId}) async {
    final snapshot = await _firestore
        .collection(_jobsCollection)
        .where('slug', isEqualTo: slug)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return true;
    if (excludeId != null && snapshot.docs.first.id == excludeId) return true;
    return false;
  }

  Future<String> addJob(JobPosting job) async {
    final doc = await _firestore.collection(_jobsCollection).add(job.toMap());
    return doc.id;
  }

  Future<void> updateJob(JobPosting job) async {
    await _firestore
        .collection(_jobsCollection)
        .doc(job.id)
        .update(job.toMap());
  }

  Future<void> deleteJob(String id) async {
    await _firestore.collection(_jobsCollection).doc(id).delete();
  }

  Future<void> incrementJobViewCount(String jobId) async {
    await _firestore.collection(_jobsCollection).doc(jobId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  // ============== PORTFOLIO VIEW DATA ==============

  /// Get data for the public portfolio view
  /// If jobSlug is provided, returns job-specific content
  /// Otherwise returns default/generic content
  Future<PortfolioViewData> getPortfolioViewData(String? jobSlug) async {
    final settings = await getSettings();

    JobPosting? job;
    List<Project> projects;
    List<Experience> experiences;

    if (jobSlug != null && jobSlug.isNotEmpty) {
      // Job-specific view
      job = await getJobBySlug(jobSlug);

      if (job != null && job.isActive) {
        // Increment view count
        incrementJobViewCount(job.id);

        // Get selected projects and experience for this job
        projects = await getProjectsByIds(job.projectIds);
        experiences = await getExperienceByIds(job.experienceIds);
      } else {
        // Job not found or inactive, fall back to default
        projects = await _getDefaultProjects(settings);
        experiences = await _getDefaultExperience(settings);
      }
    } else {
      // Generic homepage
      projects = await _getDefaultProjects(settings);
      experiences = await _getDefaultExperience(settings);
    }

    return PortfolioViewData(
      settings: settings,
      projects: projects,
      experiences: experiences,
      jobPosting: job,
    );
  }

  Future<List<Project>> _getDefaultProjects(PortfolioSettings settings) async {
    if (settings.defaultProjectIds.isNotEmpty) {
      return getProjectsByIds(settings.defaultProjectIds);
    }
    return getActiveProjects();
  }

  Future<List<Experience>> _getDefaultExperience(
    PortfolioSettings settings,
  ) async {
    if (settings.defaultExperienceIds.isNotEmpty) {
      return getExperienceByIds(settings.defaultExperienceIds);
    }
    return getActiveExperience();
  }

}
