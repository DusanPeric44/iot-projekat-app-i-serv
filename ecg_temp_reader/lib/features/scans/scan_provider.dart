import 'package:flutter/foundation.dart';

import '../../data/models/scan_session.dart';
import '../../data/repositories/scan_repository.dart';

class ScanProvider extends ChangeNotifier {
  final ScanRepository _repo;
  List<ScanSession> _scans = [];
  bool _loading = false;

  ScanProvider(this._repo);

  List<ScanSession> get scans => _scans;
  bool get loading => _loading;

  Future<void> load(int userId) async {
    _loading = true;
    _scans = await _repo.getScansForUser(userId);
    _loading = false;
    notifyListeners();
  }

  Future<int> save(ScanSession scan) async {
    final id = await _repo.insertScan(scan);
    _scans = [scan.copyWith(id: id), ..._scans];
    notifyListeners();
    return id;
  }

  Future<void> delete(int id) async {
    await _repo.deleteScan(id);
    _scans = _scans.where((e) => e.id != id).toList();
    notifyListeners();
  }
}
