import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calisan.dart';

class CalisanSaglayici with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Calisan> _calisanlar = [];

  // Firestore'dan personel verilerini yükle
  Future<void> calisanlariYukle() async {
    try {
      final snapshot = await _firestore.collection('employees').get();
      final List<Calisan> yuklenenCalisanlar = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        yuklenenCalisanlar.add(Calisan(
          id: doc.id,
          ad: data['name'],
          telefon: data['phone'],
          rol: data['role'],
          baslangicTarihi: DateTime.parse(data['startDate']),
          aktifMi: data['isActive'] ?? true,
          puan: data['rating']?.toDouble() ?? 0.0,
          puanSayisi: data['ratingCount'] ?? 0,
        ));
      }

      _calisanlar.clear();
      _calisanlar.addAll(yuklenenCalisanlar);
      notifyListeners();
      print('Personel listesi başarıyla yüklendi');
    } catch (e) {
      print('Personel yükleme hatası: $e');
    }
  }

  // Varsayılan personel verilerini yükle
  Future<void> varsayilanCalisanlariYukle() async {
    try {
      final batch = _firestore.batch();

      final varsayilanCalisanlar = [
        {
          'name': 'Ahmet Yılmaz',
          'phone': '0555 111 2233',
          'role': 'Garson',
          'startDate': DateTime(2023, 1, 15).toIso8601String(),
          'isActive': true,
          'rating': 0.0,
          'ratingCount': 0,
        },
        {
          'name': 'Mehmet Şahin',
          'phone': '0532 222 3344',
          'role': 'Aşçı',
          'startDate': DateTime(2023, 3, 1).toIso8601String(),
          'isActive': true,
          'rating': 0.0,
          'ratingCount': 0,
        },
        {
          'name': 'Ayşe Demir',
          'phone': '0533 333 4455',
          'role': 'Garson',
          'startDate': DateTime(2023, 6, 10).toIso8601String(),
          'isActive': true,
          'rating': 0.0,
          'ratingCount': 0,
        },
        {
          'name': 'Fatma Öztürk',
          'phone': '0544 444 5566',
          'role': 'Komi',
          'startDate': DateTime(2023, 8, 20).toIso8601String(),
          'isActive': true,
          'rating': 0.0,
          'ratingCount': 0,
        },
      ];

      for (var calisan in varsayilanCalisanlar) {
        final docRef = _firestore.collection('employees').doc();
        batch.set(docRef, calisan);
      }

      await batch.commit();
      print('Varsayılan personel listesi yüklendi');
      await calisanlariYukle();
    } catch (e) {
      print('Varsayılan personel yükleme hatası: $e');
    }
  }

  // CRUD işlemleri
  Future<void> calisanEkle(Calisan calisan) async {
    try {
      final docRef = await _firestore.collection('employees').add({
        'name': calisan.ad,
        'phone': calisan.telefon,
        'role': calisan.rol,
        'startDate': calisan.baslangicTarihi.toIso8601String(),
        'isActive': calisan.aktifMi,
        'rating': calisan.puan,
        'ratingCount': calisan.puanSayisi,
      });

      final yeniCalisan = Calisan(
        id: docRef.id,
        ad: calisan.ad,
        telefon: calisan.telefon,
        rol: calisan.rol,
        baslangicTarihi: calisan.baslangicTarihi,
        aktifMi: calisan.aktifMi,
        puan: calisan.puan,
        puanSayisi: calisan.puanSayisi,
      );

      _calisanlar.add(yeniCalisan);
      notifyListeners();
    } catch (e) {
      print('Personel ekleme hatası: $e');
    }
  }

  // Personel durumunu değiştir
  Future<void> calisanDurumDegistir(String calisanId) async {
    try {
      final index = _calisanlar.indexWhere((cal) => cal.id == calisanId);
      if (index >= 0) {
        final calisan = _calisanlar[index];
        final yeniDurum = !calisan.aktifMi;

        // Firestore'da güncelle
        await _firestore.collection('employees').doc(calisanId).update({
          'isActive': yeniDurum,
        });

        // Yerel listeyi güncelle
        _calisanlar[index] = calisan.kopya(aktifMi: yeniDurum);
        notifyListeners();

        print(
            'Personel durumu güncellendi: ${calisan.ad} - ${yeniDurum ? 'Aktif' : 'Pasif'}');
      }
    } catch (e) {
      print('Personel durumu güncelleme hatası: $e');
      rethrow;
    }
  }

  // Personel güncelleme
  Future<void> calisanGuncelle(Calisan guncelCalisan) async {
    try {
      await _firestore.collection('employees').doc(guncelCalisan.id).update({
        'name': guncelCalisan.ad,
        'phone': guncelCalisan.telefon,
        'role': guncelCalisan.rol,
        'startDate': guncelCalisan.baslangicTarihi.toIso8601String(),
        'isActive': guncelCalisan.aktifMi,
        'rating': guncelCalisan.puan,
        'ratingCount': guncelCalisan.puanSayisi,
      });

      final index = _calisanlar.indexWhere((cal) => cal.id == guncelCalisan.id);
      if (index >= 0) {
        _calisanlar[index] = guncelCalisan;
        notifyListeners();
      }
    } catch (e) {
      print('Personel güncelleme hatası: $e');
      rethrow;
    }
  }

  // Personel silme
  Future<void> calisanSil(String calisanId) async {
    try {
      await _firestore.collection('employees').doc(calisanId).delete();
      _calisanlar.removeWhere((cal) => cal.id == calisanId);
      notifyListeners();
    } catch (e) {
      print('Personel silme hatası: $e');
      rethrow;
    }
  }

  // Personel puanlama
  Future<void> calisanPuanla(String calisanId, double puan) async {
    try {
      final index = _calisanlar.indexWhere((cal) => cal.id == calisanId);
      if (index >= 0) {
        final calisan = _calisanlar[index];
        final toplamPuan = (calisan.puan * calisan.puanSayisi) + puan;
        final yeniSayisi = calisan.puanSayisi + 1;
        final yeniPuan = toplamPuan / yeniSayisi;

        // Firestore'da güncelle
        await _firestore.collection('employees').doc(calisanId).update({
          'rating': yeniPuan,
          'ratingCount': yeniSayisi,
        });

        // Yerel listeyi güncelle
        _calisanlar[index] = calisan.kopya(
          puan: yeniPuan,
          puanSayisi: yeniSayisi,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Personel puanlama hatası: $e');
      rethrow;
    }
  }

  List<Calisan> get calisanlar => [..._calisanlar];
  List<Calisan> get aktifCalisanlar =>
      _calisanlar.where((cal) => cal.aktifMi).toList();
  List<Calisan> get aktifGarsonlar => _calisanlar
      .where((cal) => cal.aktifMi && cal.rol.toLowerCase().contains('garson'))
      .toList();
}
