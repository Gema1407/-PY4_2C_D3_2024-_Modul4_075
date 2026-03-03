import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logbook_app_075/services/mongo_service.dart';
import 'models/log_model.dart';
import 'package:logbook_app_075/helpers/log_helper.dart'; // import untuk file controller ini

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final String _storageKey;

  LogController(String username) : _storageKey = 'user_logs_$username';

  Future<void> addLog(
    String title,
    String desc, {
    String category = 'Umum',
  }) async {
    final newLog = LogModel(
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      category: category,
    );
    // Simpan ke Cloud
    await MongoService().insertLog(newLog);
    // Refresh List Notifier setelah simpan ke Cloud
    await loadFromDisk();
  }

  Future<void> updateLog(
    int index,
    String title,
    String desc, {
    String category = 'Umum',
  }) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    final updatedLog = LogModel(
      id: targetLog.id, // Pertahankan ID saat update!
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      category: category,
    );

    // Update di Cloud
    await MongoService().updateLog(updatedLog);
    // Refresh List Notifier
    await loadFromDisk();
  }

  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final logId = currentLogs[index].id;

    if (logId != null) {
      await MongoService().deleteLog(logId);
      // Refresh List Notifier
      await loadFromDisk();
    }
  }

  // loadFromDisk diubah untuk mengambil data dari MongoDB,
  // namanya dipertahankan loadFromDisk agar tidak error di view
  Future<void> loadFromDisk() async {
    try {
      final logsFromDb = await MongoService().getLogs();
      logsNotifier.value = logsFromDb;
    } catch (e) {
      await LogHelper.writeLog(
        "Failed to sync from Mongo: $e",
        source: "log_controller.dart",
        level: 1,
      );
      logsNotifier.value = []; // Jika gagal, set List ke kosong
    }
  }
}
