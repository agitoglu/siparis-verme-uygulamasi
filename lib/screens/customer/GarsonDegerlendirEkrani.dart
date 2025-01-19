import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/calisan.dart';
import '../../providers/CalisanSaglayici.dart';

class GarsonDegerlendirEkrani extends StatelessWidget {
  const GarsonDegerlendirEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalisanSaglayici>(
      builder: (context, calisanProvider, child) {
        final garsonlar = calisanProvider.aktifGarsonlar;

        if (garsonlar.isEmpty) {
          return const Center(
            child: Text(
              'Aktif garson bulunmamaktadır',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: garsonlar.length,
          itemBuilder: (context, index) {
            final garson = garsonlar[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: const Icon(Icons.person, color: Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              garson.ad,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                Text(
                                  ' ${garson.puan.toStringAsFixed(1)} (${garson.puanSayisi} değerlendirme)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Puanınız:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (yildizIndex) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            size: 32,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            final rating = yildizIndex + 1.0;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Garson Değerlendirme'),
                                content: Text(
                                  '${garson.ad} adlı garsona $rating yıldız vermek istediğinize emin misiniz?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('İptal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      calisanProvider.calisanPuanla(
                                        garson.id,
                                        rating,
                                      );
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Değerlendirmeniz için teşekkürler!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    child: const Text('Onayla'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
