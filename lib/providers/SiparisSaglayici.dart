import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/siparis.dart';
import '../models/Urun.dart';

typedef TableOrderCallback = void Function(
    int masaNumarasi, List<SiparisElemani> siparisler);

class SiparisSaglayici with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<int, List<SiparisElemani>> _masaSiparisleri = {};
  final List<TableOrderCallback> _masaDinleyiciler = [];

  Map<int, List<SiparisElemani>> get masaSiparisler => {..._masaSiparisleri};

  void masaDinleyiciEkle(TableOrderCallback dinleyici) {
    _masaDinleyiciler.add(dinleyici);
  }

  void masaDinleyiciKaldir(TableOrderCallback dinleyic) {
    _masaDinleyiciler.remove(dinleyic);
  }

  List<SiparisElemani> masaIcinSiparisleriGetir(int masaNumarasi) {
    return _masaSiparisleri[masaNumarasi] ?? [];
  }

  void _masaDinleyicileriBilgilendi(int masaNumarasi) {
    for (var dinleyici in _masaDinleyiciler) {
      dinleyici(masaNumarasi, _masaSiparisleri[masaNumarasi] ?? []);
    }
  }

  double masaToplaminiGetir(int masaNumarasi) {
    if (!_masaSiparisleri.containsKey(masaNumarasi)) return 0;
    return _masaSiparisleri[masaNumarasi]!
        .fold(0, (toplam, eleman) => toplam + eleman.toplamFiyat);
  }

  List<int> get aktifMasaNumaralari => _masaSiparisleri.keys.toList()..sort();

  // Firestore işlemleri
  Future<void> baslat() async {
    await siparisleriYukle();
  }

  Future<void> siparisleriYukle() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('isPaid', isEqualTo: false)
          .get();

      final Map<int, List<SiparisElemani>> yuklenenSiparisler = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final masaNumarasi = data['tableNumber'] as int;
        final elemanlar = (data['items'] as List).map((item) {
          final urunMap = item['product'] as Map<String, dynamic>;
          return SiparisElemani(
            urun: Urun.haritaIleOlustur(urunMap),
            adet: item['quantity'] as int,
          );
        }).toList();

        if (!yuklenenSiparisler.containsKey(masaNumarasi)) {
          yuklenenSiparisler[masaNumarasi] = [];
        }
        yuklenenSiparisler[masaNumarasi]!.addAll(elemanlar);
      }

      _masaSiparisleri.clear();
      _masaSiparisleri.addAll(yuklenenSiparisler);
      notifyListeners();
    } catch (e) {
      print('Sipariş yükleme hatası: $e');
      rethrow;
    }
  }

  Future<void> siparisEkle(
      int masaNumarasi, List<SiparisElemani> elemanlar) async {
    try {
      final siparisVerisi = {
        'tableNumber': masaNumarasi,
        'orderTime': DateTime.now().toIso8601String(),
        'items': elemanlar
            .map((eleman) => {
                  'product': eleman.urun.haritaYap(),
                  'quantity': eleman.adet,
                })
            .toList(),
        'isPaid': false,
        'totalAmount': elemanlar.fold(
            0.0, (toplam, eleman) => toplam + eleman.toplamFiyat),
      };

      await _firestore.collection('orders').add(siparisVerisi);

      if (!_masaSiparisleri.containsKey(masaNumarasi)) {
        _masaSiparisleri[masaNumarasi] = [];
      }
      _masaSiparisleri[masaNumarasi]!.addAll(elemanlar);

      _masaDinleyicileriBilgilendi(masaNumarasi);
      notifyListeners();
    } catch (e) {
      print('Sipariş ekleme hatası: $e');
      rethrow;
    }
  }

  Future<void> masaOdendi(int masaNumarasi) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('tableNumber', isEqualTo: masaNumarasi)
          .where('isPaid', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isPaid': true});
      }
      await batch.commit();

      _masaSiparisleri.remove(masaNumarasi);
      _masaDinleyicileriBilgilendi(masaNumarasi);
      notifyListeners();
    } catch (e) {
      print('Masa hesap ödeme hatası: $e');
      rethrow;
    }
  }

  Future<void> siparisElemaniSil(int masaNumarasi, String urunId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('tableNumber', isEqualTo: masaNumarasi)
          .where('isPaid', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        final elemanlar = (doc.data()['items'] as List)
            .where((eleman) =>
                (eleman['product'] as Map<String, dynamic>)['id'] != urunId)
            .toList();

        if (elemanlar.isEmpty) {
          await doc.reference.delete();
        } else {
          await doc.reference.update({'items': elemanlar});
        }
      }

      if (_masaSiparisleri.containsKey(masaNumarasi)) {
        _masaSiparisleri[masaNumarasi]!
            .removeWhere((eleman) => eleman.urun.id == urunId);
        if (_masaSiparisleri[masaNumarasi]!.isEmpty) {
          _masaSiparisleri.remove(masaNumarasi);
        }
        _masaDinleyicileriBilgilendi(masaNumarasi);
        notifyListeners();
      }
    } catch (e) {
      print('Sipariş öğesi silme hatası: $e');
      rethrow;
    }
  }

  Future<void> siparisMiktariniGuncelle(
      int masaNumarasi, String urunId, int yeniMiktar) async {
    try {
      if (yeniMiktar <= 0) {
        await siparisElemaniSil(masaNumarasi, urunId);
        return;
      }

      final snapshot = await _firestore
          .collection('orders')
          .where('tableNumber', isEqualTo: masaNumarasi)
          .where('isPaid', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        final elemanlar = (doc.data()['items'] as List).map((eleman) {
          if ((eleman['product'] as Map<String, dynamic>)['id'] == urunId) {
            return {...eleman, 'quantity': yeniMiktar};
          }
          return eleman;
        }).toList();

        await doc.reference.update({'items': elemanlar});
      }

      if (_masaSiparisleri.containsKey(masaNumarasi)) {
        final index = _masaSiparisleri[masaNumarasi]!
            .indexWhere((eleman) => eleman.urun.id == urunId);
        if (index != -1) {
          _masaSiparisleri[masaNumarasi]![index].adet = yeniMiktar;
          _masaDinleyicileriBilgilendi(masaNumarasi);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Sipariş miktarı güncelleme hatası: $e');
      rethrow;
    }
  }

  Future<void> masaTemizle(int masaNumarasi) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('tableNumber', isEqualTo: masaNumarasi)
          .where('isPaid', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _masaSiparisleri.remove(masaNumarasi);
      _masaDinleyicileriBilgilendi(masaNumarasi);
      notifyListeners();
    } catch (e) {
      print('Masa temizleme hatası: $e');
      rethrow;
    }
  }

  // Boş orders koleksiyonunu oluştur
  Future<void> varsayilanSiparisleriYukle() async {
    try {
      // Önce mevcut koleksiyonu temizle
      final snapshot = await _firestore.collection('orders').get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Mevcut orders koleksiyonu temizlendi');

      // Boş koleksiyonu oluştur
      await _firestore.collection('orders').add({
        'isInitialized': true,
        'createdAt': DateTime.now().toIso8601String(),
      });

      print('Boş orders koleksiyonu oluşturuldu');
      await siparisleriYukle();
    } catch (e) {
      print('Orders koleksiyonu oluşturma hatası: $e');
      rethrow;
    }
  }
}
