import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/siparis.dart';
import '../models/Urun.dart';
import 'SiparisSaglayici.dart';

class SepetSaglayici with ChangeNotifier {
  final List<SiparisElemani> _elemanlar = [];
  final List<SiparisElemani> _onaylanmisElemanlar = [];
  int? masaNumarasi;
  double _onaylanmisToplam = 0.0;
  SiparisSaglayici? _siparisSaglayici;

  List<SiparisElemani> get elemanlar => [..._elemanlar];
  List<SiparisElemani> get onaylanmisElemanlar => [..._onaylanmisElemanlar];
  double get onaylanmisToplam => _onaylanmisToplam;

  double get toplamTutar {
    return _elemanlar.fold(0, (toplam, eleman) => toplam + eleman.toplamFiyat);
  }

  void elemanEkle(Urun urun) {
    // Önce onaylanmış siparişlerde bu üründen var mı kontrol et
    final mevcutOnayIndex =
        _onaylanmisElemanlar.indexWhere((eleman) => eleman.urun.id == urun.id);

    // Sonra mevcut sepette bu üründen var mı kontrol et
    final mevcutSepetIndex =
        _elemanlar.indexWhere((eleman) => eleman.urun.id == urun.id);

    if (mevcutSepetIndex >= 0) {
      // Eğer ürün sepette varsa miktarını artır
      _elemanlar[mevcutSepetIndex].adet += 1;
    } else {
      // Eğer ürün sepette yoksa yeni ekle
      _elemanlar.add(SiparisElemani(urun: urun));
    }

    notifyListeners();
  }

  void elemanCikar(String urunId) {
    _elemanlar.removeWhere((eleman) => eleman.urun.id == urunId);
    notifyListeners();
  }

  void masaNumarasiAyarla(int numara) {
    masaNumarasi = numara;

    // Masa değiştiğinde, o masanın siparişlerini yükle
    if (_siparisSaglayici != null) {
      final siparisler = _siparisSaglayici!.masaIcinSiparisleriGetir(numara);
      onaylanmisSiparisleriGuncelle(siparisler);
    }

    notifyListeners();
  }

  void temizle() {
    _elemanlar.clear();
    notifyListeners();
  }

  void miktarArttir(String urunId) {
    final index = _elemanlar.indexWhere((eleman) => eleman.urun.id == urunId);
    if (index >= 0) {
      _elemanlar[index].adet += 1;
      notifyListeners();
    }
  }

  void miktarAzalt(String urunId) {
    final index = _elemanlar.indexWhere((eleman) => eleman.urun.id == urunId);
    if (index >= 0) {
      if (_elemanlar[index].adet > 0) {
        _elemanlar[index].adet -= 1;
        if (_elemanlar[index].adet == 0) {
          _elemanlar.removeAt(index); // Adet 0 olunca ürünü sil
        }
      }
      notifyListeners();
    }
  }

  Future<void> siparisiOnayla() async {
    if (masaNumarasi != null && _elemanlar.isNotEmpty) {
      try {
        await _siparisSaglayici?.siparisEkle(masaNumarasi!, _elemanlar);
        _elemanlar.clear();
        notifyListeners();
      } catch (e) {
        print('Sipariş onaylama hatası: $e');
        rethrow;
      }
    }
  }

  void onaylanmisSiparisleriGuncelle(List<SiparisElemani> guncelSiparisler) {
    _onaylanmisElemanlar.clear();
    _onaylanmisElemanlar.addAll(guncelSiparisler);

    // Toplam tutarı güncelle
    _onaylanmisToplam = _onaylanmisElemanlar.fold(
      0,
      (toplam, eleman) => toplam + (eleman.urun.fiyat * eleman.adet),
    );

    notifyListeners();
  }

  void baslat(BuildContext context) {
    _siparisSaglayici = context.read<SiparisSaglayici>();
    _siparisSaglayici?.masaDinleyiciEkle(_masaSiparisleriDegisti);

    // Mevcut masa siparişlerini yükle
    if (masaNumarasi != null) {
      final siparisler =
          _siparisSaglayici?.masaIcinSiparisleriGetir(masaNumarasi!);
      if (siparisler != null) {
        onaylanmisSiparisleriGuncelle(siparisler);
      }
    }
  }

  @override
  void dispose() {
    if (_siparisSaglayici != null) {
      _siparisSaglayici!.masaDinleyiciKaldir(_masaSiparisleriDegisti);
    }
    super.dispose();
  }

  void _masaSiparisleriDegisti(int masaNo, List<SiparisElemani> siparisler) {
    // Sadece aktif masanın siparişlerini güncelle
    if (masaNo == masaNumarasi) {
      onaylanmisSiparisleriGuncelle(siparisler);
    }
  }
}
