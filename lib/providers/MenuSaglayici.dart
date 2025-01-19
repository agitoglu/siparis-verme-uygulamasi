import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Urun.dart';

class MenuSaglayici with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, List<Urun>> _menuOgeleri = {};

  // Getter'lar
  Map<String, List<Urun>> get menuOgeleri => {..._menuOgeleri};
  List<String> get kategoriler => _menuOgeleri.keys.toList();

  // Firestore'dan menüyü yükle
  Future<void> menuYukle() async {
    try {
      final snapshot = await _firestore.collection('menu').get();
      final Map<String, List<Urun>> yuklenenMenu = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final urun = Urun(
          id: doc.id,
          ad: data['name'],
          fiyat: data['price'].toDouble(),
          aciklama: data['description'],
          kategori: data['category'],
        );

        if (!yuklenenMenu.containsKey(urun.kategori)) {
          yuklenenMenu[urun.kategori] = [];
        }
        yuklenenMenu[urun.kategori]!.add(urun);
      }

      _menuOgeleri.clear();
      _menuOgeleri.addAll(yuklenenMenu);
      notifyListeners();
    } catch (e) {
      print('Menü yükleme hatası: $e');
      rethrow; // Hatayı yukarı fırlat
    }
  }

  // Ürün ekleme
  Future<void> urunEkle(Urun urun) async {
    try {
      // Önce Firestore'a ekle
      final docRef = await _firestore.collection('menu').add({
        'name': urun.ad,
        'price': urun.fiyat,
        'description': urun.aciklama,
        'category': urun.kategori,
      });

      // Yeni ürünü oluştur
      final yeniUrun = urun.kopya(id: docRef.id);

      // Yerel listeyi güncelle
      if (!_menuOgeleri.containsKey(urun.kategori)) {
        _menuOgeleri[urun.kategori] = [];
      }
      _menuOgeleri[urun.kategori]!.add(yeniUrun);

      // loadMenu() çağrısını kaldırdık
      notifyListeners();
    } catch (e) {
      print('Ürün ekleme hatası: $e');
      rethrow;
    }
  }

  // Ürün güncelleme
  Future<void> urunGuncelle(Urun guncelUrun) async {
    try {
      await _firestore.collection('menu').doc(guncelUrun.id).update({
        'name': guncelUrun.ad,
        'price': guncelUrun.fiyat,
        'description': guncelUrun.aciklama,
        'category': guncelUrun.kategori,
      });

      final kategori = guncelUrun.kategori;
      final index = _menuOgeleri[kategori]?.indexWhere(
            (urun) => urun.id == guncelUrun.id,
          ) ??
          -1;

      if (index >= 0) {
        _menuOgeleri[kategori]![index] = guncelUrun;
        notifyListeners();
      }
    } catch (e) {
      print('Ürün güncelleme hatası: $e');
      rethrow;
    }
  }

  // Ürün silme
  Future<void> urunSil(String kategori, String urunId) async {
    try {
      await _firestore.collection('menu').doc(urunId).delete();

      if (_menuOgeleri.containsKey(kategori)) {
        _menuOgeleri[kategori]?.removeWhere((urun) => urun.id == urunId);
        if (_menuOgeleri[kategori]?.isEmpty ?? false) {
          _menuOgeleri.remove(kategori);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Ürün silme hatası: $e');
      rethrow;
    }
  }
}
