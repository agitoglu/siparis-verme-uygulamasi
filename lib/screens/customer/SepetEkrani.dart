import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/SepetSaglayici.dart';

class SepetEkrani extends StatelessWidget {
  const SepetEkrani({super.key});

  Future<void> _siparisOnayDialogunuGoster(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sipariş Onayı'),
        content: const Text('Siparişinizi onaylamak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _siparisiOnayla(context);
            },
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }

  Future<void> _siparisiOnayla(BuildContext context) async {
    try {
      final sepetSaglayici = context.read<SepetSaglayici>();
      await sepetSaglayici.siparisiOnayla();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Siparişiniz başarıyla alındı'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sipariş alınırken bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SepetSaglayici>(
      builder: (context, sepet, child) {
        if (sepet.elemanlar.isEmpty) {
          return const Center(
            child: Text('Sepetiniz boş'),
          );
        }

        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: sepet.elemanlar.length,
            itemBuilder: (context, index) {
              final item = sepet.elemanlar[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Sol taraf - İkon ve ürün bilgileri
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Icon(
                                item.urun.kategori == 'Yiyecekler'
                                    ? Icons.fastfood
                                    : item.urun.kategori == 'İçecekler'
                                        ? Icons.local_drink
                                        : Icons.cake,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.urun.ad,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.urun.fiyat} TL',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Sağ taraf - Adet kontrolü ve toplam fiyat
                      Expanded(
                        flex: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Adet kontrolü
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.red,
                              onPressed: () => sepet.miktarAzalt(item.urun.id),
                            ),
                            SizedBox(
                              width: 35,
                              child: Text(
                                '${item.adet}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: Colors.green,
                              onPressed: () => sepet.miktarArttir(item.urun.id),
                            ),
                            // Toplam fiyat
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.toplamFiyat.toStringAsFixed(2)} TL',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      sepet.elemanCikar(item.urun.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Toplam Tutar:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${sepet.toplamTutar.toStringAsFixed(2)} TL',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _siparisOnayDialogunuGoster(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Siparişi Onayla',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
