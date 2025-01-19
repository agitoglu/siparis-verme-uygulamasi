class Calisan {
  final String id;
  final String ad;
  final String telefon;
  final String rol;
  final DateTime baslangicTarihi;
  final bool aktifMi;
  final double puan; // Ortalama puan
  final int puanSayisi; // Kaç kişi puan vermiş

  Calisan({
    required this.id,
    required this.ad,
    required this.telefon,
    required this.rol,
    required this.baslangicTarihi,
    this.aktifMi = true,
    this.puan = 0.0,
    this.puanSayisi = 0,
  });

  Calisan kopya({
    String? id,
    String? ad,
    String? telefon,
    String? rol,
    DateTime? baslangicTarihi,
    bool? aktifMi,
    double? puan,
    int? puanSayisi,
  }) {
    return Calisan(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      telefon: telefon ?? this.telefon,
      rol: rol ?? this.rol,
      baslangicTarihi: baslangicTarihi ?? this.baslangicTarihi,
      aktifMi: aktifMi ?? this.aktifMi,
      puan: puan ?? this.puan,
      puanSayisi: puanSayisi ?? this.puanSayisi,
    );
  }

  Map<String, dynamic> haritaYap() {
    return {
      'id': id,
      'name': ad,
      'phone': telefon,
      'role': rol,
      'startDate': baslangicTarihi.toIso8601String(),
      'isActive': aktifMi,
      'rating': puan,
      'ratingCount': puanSayisi,
    };
  }

  factory Calisan.haritaIleOlustur(Map<String, dynamic> harita) {
    return Calisan(
      id: harita['id'],
      ad: harita['name'],
      telefon: harita['phone'],
      rol: harita['role'],
      baslangicTarihi: DateTime.parse(harita['startDate']),
      aktifMi: harita['isActive'] ?? true,
      puan: harita['rating']?.toDouble() ?? 0.0,
      puanSayisi: harita['ratingCount'] ?? 0,
    );
  }
}
