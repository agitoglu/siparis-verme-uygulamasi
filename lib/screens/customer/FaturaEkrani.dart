import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/SepetSaglayici.dart';
import '../../models/siparis.dart';

class FaturaEkrani extends StatelessWidget {
  const FaturaEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SepetSaglayici>(
      builder: (context, sepet, child) {
        final mevcutSiparisler = sepet.elemanlar.isNotEmpty;
        final onaylanmisSiparisler = sepet.onaylanmisElemanlar.isNotEmpty;

        if (!mevcutSiparisler && !onaylanmisSiparisler) {
          return const Center(
            child: Text('Henüz sipariş verilmedi'),
          );
        }

        return Scaffold(
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Masa ${sepet.masaNumarasi}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toplam Tutar: ${(sepet.toplamTutar + sepet.onaylanmisToplam).toStringAsFixed(2)} TL',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${sepet.elemanlar.length + sepet.onaylanmisElemanlar.length} Ürün',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    if (onaylanmisSiparisler) ...[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Onaylanan Siparişler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      ...sepet.onaylanmisElemanlar
                          .map((item) => _buildOrderItem(
                                context,
                                item,
                                isConfirmed: true,
                              )),
                      const Divider(thickness: 2),
                    ],
                    if (mevcutSiparisler) ...[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Bekleyen Siparişler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      ...sepet.elemanlar.map((item) =>
                          _buildOrderItem(context, item, isConfirmed: false)),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onaylanmisSiparisler)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Onaylanan Siparişler:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '${sepet.onaylanmisToplam.toStringAsFixed(2)} TL',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (mevcutSiparisler)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bekleyen Siparişler:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.orange,
                              ),
                            ),
                            Text(
                              '${sepet.toplamTutar.toStringAsFixed(2)} TL',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Genel Toplam:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(sepet.toplamTutar + sepet.onaylanmisToplam).toStringAsFixed(2)} TL',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(BuildContext context, SiparisElemani item,
      {required bool isConfirmed}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            item.urun.kategori == 'Yiyecekler'
                ? Icons.fastfood
                : item.urun.kategori == 'İçecekler'
                    ? Icons.local_drink
                    : Icons.cake,
            color: isConfirmed ? Colors.green : Colors.orange,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.urun.ad,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isConfirmed
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.adet}x',
                style: TextStyle(
                  color: isConfirmed ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Birim Fiyat: ${item.urun.fiyat} TL',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          '${item.toplamFiyat.toStringAsFixed(2)} TL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isConfirmed ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }
}
