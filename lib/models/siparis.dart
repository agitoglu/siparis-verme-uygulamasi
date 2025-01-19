import 'Urun.dart';

class SiparisElemani {
  final Urun urun;
  int adet;

  SiparisElemani({
    required this.urun,
    this.adet = 1,
  });

  double get toplamFiyat => urun.fiyat * adet;
}

class Siparis {
  final String id;
  final int masaNumarasi;
  final List<SiparisElemani> elemanlar;
  final DateTime siparisZamani;
  bool odendiMi;

  Siparis({
    required this.id,
    required this.masaNumarasi,
    required this.elemanlar,
    required this.siparisZamani,
    this.odendiMi = false,
  });

  double get toplamTutar {
    return elemanlar.fold(0, (toplam, eleman) => toplam + eleman.toplamFiyat);
  }
}
