import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../jobs/services/jobs_service.dart';
import '../../../models/job_model.dart';

class SavedProvider extends ChangeNotifier {
  final JobsService _service = JobsService();

  Set<String> _savedIds = {};
  List<Map<String, dynamic>> _savedJobs = [];
  StreamSubscription? _idSub;
  StreamSubscription? _jobSub;

  Set<String> get savedIds => _savedIds;
  List<Map<String, dynamic>> get savedJobs => _savedJobs;
  bool isSaved(String id) => _savedIds.contains(id);

  void startListening() {
    _idSub?.cancel();
    _jobSub?.cancel();
    _idSub = _service.savedIdsStream().listen((ids) {
      _savedIds = ids;
      notifyListeners();
    });
    _jobSub = _service.savedJobsStream().listen((jobs) {
      _savedJobs = jobs;
      notifyListeners();
    });
  }

  Future<void> toggle(JobModel job) async {
    await _service.toggleSaved(job);
  }

  @override
  void dispose() {
    _idSub?.cancel();
    _jobSub?.cancel();
    super.dispose();
  }
}