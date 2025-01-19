class Urun {
  final String id;
  final String ad;
  final double fiyat;
  final String aciklama;
  final String kategori;

  Urun({
    required this.id,
    required this.ad,
    required this.fiyat,
    required this.aciklama,
    required this.kategori,
  });

  Urun kopya({
    String? id,
    String? ad,
    double? fiyat,
    String? aciklama,
    String? kategori,
  }) {
    return Urun(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      fiyat: fiyat ?? this.fiyat,
      aciklama: aciklama ?? this.aciklama,
      kategori: kategori ?? this.kategori,
    );
  }

  Map<String, dynamic> haritaYap() {
    return {
      'id': id,
      'name': ad,
      'price': fiyat,
      'description': aciklama,
      'category': kategori,
    };
  }

  factory Urun.haritaIleOlustur(Map<String, dynamic> harita) {
    return Urun(
      id: harita['id'],
      ad: harita['name'],
      fiyat: harita['price'].toDouble(),
      aciklama: harita['description'],
      kategori: harita['category'],
    );
  }
}
