import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YoneticiSaglayici with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> yoneticiKoleksiyonuOlustur() async {
    try {
      final koleksiyonRef = _firestore.collection('admin');
      final snapshot = await koleksiyonRef.get();

      if (snapshot.docs.isEmpty) {
        await koleksiyonRef.doc('settings').set({
          'password': '123456',
          'lastUpdated': DateTime.now().toIso8601String(),
        });
        print('Admin koleksiyonu ve settings dokümanı oluşturuldu');
      } else {
        print('Admin koleksiyonu zaten var');
      }
    } catch (e) {
      print('Admin koleksiyonu oluşturma hatası: $e');
      rethrow;
    }
  }

  Future<bool> sifreKontrol(String sifre) async {
    try {
      final dokuman =
          await _firestore.collection('admin').doc('settings').get();
      if (dokuman.exists) {
        return dokuman.data()?['password'] == sifre;
      }
      return false;
    } catch (e) {
      print('Şifre kontrol hatası: $e');
      return false;
    }
  }

  Future<void> sifreGuncelle(String yeniSifre) async {
    try {
      final dokumanRef = _firestore.collection('admin').doc('settings');

      await dokumanRef.set({
        'password': yeniSifre,
        'lastUpdated': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      print('Şifre güncellendi');
      notifyListeners();
    } catch (e) {
      print('Şifre güncelleme hatası: $e');
      rethrow;
    }
  }
}
