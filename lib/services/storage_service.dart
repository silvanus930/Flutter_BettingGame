import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/storage_item.dart';

class StorageService {
  final _secureStorage = const FlutterSecureStorage();

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  Future<void> writeSecureData(StorageItem newItem) async {
    debugPrint("Writing new data having key ${newItem.key}");
    try {
      await _secureStorage.write(
          key: newItem.key,
          value: newItem.value,
          aOptions: _getAndroidOptions());
    } on Exception catch (_) {
      debugPrint('Error');
      await _secureStorage.deleteAll(aOptions: _getAndroidOptions());
    }
  }

  Future<String?> readSecureData(String key) async {
    debugPrint("Reading data having key $key");
    try {
      var readData =
          await _secureStorage.read(key: key, aOptions: _getAndroidOptions());
      return readData;
    } on Exception catch (_) {
      await _secureStorage.deleteAll(aOptions: _getAndroidOptions());
      return '';
    }
  }

  Future<void> deleteSecureData(StorageItem item) async {
    debugPrint("Deleting data having key ${item.key}");
    await _secureStorage.delete(key: item.key, aOptions: _getAndroidOptions());
  }

  Future<List<StorageItem>> readAllSecureData() async {
    debugPrint("Reading all secured data");
    var allData = await _secureStorage.readAll(aOptions: _getAndroidOptions());
    List<StorageItem> list =
        allData.entries.map((e) => StorageItem(e.key, e.value)).toList();
    return list;
  }

  Future<void> deleteAllSecureData() async {
    debugPrint("Deleting all secured data");
    await _secureStorage.deleteAll(aOptions: _getAndroidOptions());
  }

  Future<bool> containsKeyInSecureData(String key) async {
    debugPrint("Checking data for the key $key");
    var containsKey = await _secureStorage.containsKey(
        key: key, aOptions: _getAndroidOptions());
    return containsKey;
  }
}
