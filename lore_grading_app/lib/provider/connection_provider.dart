import 'package:flutter/foundation.dart';
import 'package:lore_grading_app/services/sync_manager.dart';

class ConnectionProvider with ChangeNotifier {
  bool _isOnline = true;
  bool _isSyncing = false;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  Future<void> toggleConnection({
    required Function onSyncStart,
    required Function onSyncComplete,
  }) async {
    _isOnline = !_isOnline;
    notifyListeners();

    if (_isOnline) {
      _isSyncing = true;
      notifyListeners();
      
      onSyncStart();

      // Trigger task and grade syncing sequentially
      await SyncManager.instance.syncTasks(_isOnline);
      await SyncManager.instance.syncGrades(_isOnline);
      
      _isSyncing = false;
      notifyListeners();

      onSyncComplete();
    }
  }

  // Triggered when manual sync is requested or when providers initialize
  Future<void> triggerSync({
    required Function onSyncStart,
    required Function onSyncComplete,
  }) async {
    if (!_isOnline || _isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    onSyncStart();

    await SyncManager.instance.syncTasks(_isOnline);
    await SyncManager.instance.syncGrades(_isOnline);

    _isSyncing = false;
    notifyListeners();

    onSyncComplete();
  }
}
