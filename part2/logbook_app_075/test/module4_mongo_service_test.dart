import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logbook_app_075/services/mongo_service.dart';
import 'package:logbook_app_075/features/logbook/models/log_model.dart';

void main() {
  group('Module 4 - MongoService (Cloud DB Connection)', () {
    late MongoService mongoService;
    late LogModel dummyLog;

    setUp(() {
      // (1) setup (arrange, build) - Data log yang akan dites
      mongoService = MongoService();
      dummyLog = LogModel(
        id: ObjectId(),
        title: "Test Cloud Unit",
        description: "Testing insertLog functionality",
        date: DateTime.now().toString(),
        category: "Umum",
      );
    });

    test(
      'TC01: insertLog should successfully save data to MongoDB (Positif)',
      () async {
        // (1) setup
        // Memuat file env asli milikmu agar bisa konek ke database benaran
        await dotenv.load(fileName: ".env");

        // (2) exercise (act, operate) & (3) verify (assert, check)
        expect(
          mongoService.insertLog(dummyLog),
          completes,
          reason:
              "Fungsi insertLog harus berhasil menyimpan data tanpa melempar error",
        );
      },
    );

    test(
      'TC02: insertLog should throw exception if MONGODB_URI is invalid (Negatif)',
      () async {
        // (1) setup
        dotenv.loadFromString(
          envString: '''MONGODB_URI=mongodb://localhost:27017/db_salah''',
        );

        // Matikan koneksi jika sedang aktif dari test sebelumnya
        await mongoService.close();

        // (2) exercise (act, operate) & (3) verify (assert, check)
        expect(
          mongoService.insertLog(dummyLog),
          throwsException,
          reason:
              "Fungsi insertLog harus melempar Exception jika URI database salah",
        );
      },
    );

    test(
      'TC03: insertLog should handle closed connection properly (Negatif/Recovery)',
      () async {
        // (1) setup
        await dotenv.load(fileName: ".env");
        await mongoService.connect(); // Buka koneksi
        await mongoService.close(); // Sengaja tutup koneksi (simulasi terputus)

        // (2) exercise (act, operate)

        // (3) verify (assert, check)
        expect(
          mongoService.insertLog(dummyLog),
          completes,
          reason:
              "Fungsi harus bisa melakukan auto-reconnect berkat _getSafeCollection",
        );
      },
    );
  });
}
