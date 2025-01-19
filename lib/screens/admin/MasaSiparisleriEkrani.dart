import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/SiparisSaglayici.dart';
import '../../models/siparis.dart';

class MasaSiparisleriEkrani extends StatelessWidget {
  const MasaSiparisleriEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SiparisSaglayici>(
      builder: (context, siparisSaglayici, child) {
        final aktifMasalar = siparisSaglayici.aktifMasaNumaralari;

        if (aktifMasalar.isEmpty) {
          return const Center(
            child: Text('Aktif sipariş bulunmamaktadır'),
          );
        }

        return ListView.builder(
          itemCount: aktifMasalar.length,
          itemBuilder: (context, index) {
            final masaNumarasi = aktifMasalar[index];
            final siparisler =
                siparisSaglayici.masaIcinSiparisleriGetir(masaNumarasi);
            final toplam = siparisSaglayici.masaToplaminiGetir(masaNumarasi);

            return Card(
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: Text('Masa $masaNumarasi'),
                subtitle: Text(
                  'Toplam Tutar: ${toplam.toStringAsFixed(2)} TL',
                  style: const TextStyle(color: Colors.green),
                ),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: siparisler.length,
                    itemBuilder: (context, orderIndex) {
                      final siparis = siparisler[orderIndex];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            siparis.urun.kategori == 'Yiyecekler'
                                ? Icons.fastfood
                                : siparis.urun.kategori == 'İçecekler'
                                    ? Icons.local_drink
                                    : Icons.cake,
                          ),
                        ),
                        title: Text(siparis.urun.ad),
                        subtitle:
                            Text('${siparis.urun.fiyat} TL x ${siparis.adet}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (siparis.adet > 1) {
                                  siparisSaglayici.siparisMiktariniGuncelle(
                                    masaNumarasi,
                                    siparis.urun.id,
                                    siparis.adet - 1,
                                  );
                                } else {
                                  _siparisSilOnayiDialogGoster(
                                    context,
                                    masaNumarasi,
                                    siparis,
                                    siparisSaglayici,
                                  );
                                }
                              },
                            ),
                            Text(
                              '${siparis.adet}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                siparisSaglayici.siparisMiktariniGuncelle(
                                  masaNumarasi,
                                  siparis.urun.id,
                                  siparis.adet + 1,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _siparisSilOnayiDialogGoster(
                                context,
                                masaNumarasi,
                                siparis,
                                siparisSaglayici,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => _odemeOnayiDialogGoster(
                        context,
                        masaNumarasi,
                        toplam,
                        siparisSaglayici,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Hesap Ödendi'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _siparisSilOnayiDialogGoster(
    BuildContext context,
    int masaNumarasi,
    SiparisElemani siparis,
    SiparisSaglayici siparisSaglayici,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Siparişi İptal Et'),
        content: Text(
          '${siparis.adet}x ${siparis.urun.ad} siparişini iptal etmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              siparisSaglayici.siparisElemaniSil(masaNumarasi, siparis.urun.id);
              Navigator.pop(context);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _odemeOnayiDialogGoster(
    BuildContext context,
    int masaNumarasi,
    double toplam,
    SiparisSaglayici siparisSaglayici,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Masa $masaNumarasi - Ödeme Onayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Toplam Tutar: ${toplam.toStringAsFixed(2)} TL'),
            const SizedBox(height: 16),
            const Text('Ödeme alındı olarak işaretlensin mi?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              siparisSaglayici.masaTemizle(masaNumarasi);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Masa $masaNumarasi hesabı ödendi'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }
}
