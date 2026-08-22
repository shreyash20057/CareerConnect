import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../models/application_model.dart';
import '../../../models/job_model.dart';
import '../../jobs/services/jobs_service.dart';

class ApplicationsProvider extends ChangeNotifier {
  final JobsService _service = JobsService();

  List<ApplicationModel> _applications = [];
  bool _isLoading = true;
  StreamSubscription? _sub;

  List<ApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;

  void startListening() {
    _sub?.cancel();
    _sub = _service.applicationStream().listen((apps) {
      _applications = apps;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> apply(JobModel job) async {
    final result = await _service.applyToJob(job);
    return result;
  }

  Future<bool> isApplied(String jobId) => _service.isApplied(jobId);

  Future<void> withdraw(String applicationId) async {
    await _service.withdrawApplication(applicationId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}