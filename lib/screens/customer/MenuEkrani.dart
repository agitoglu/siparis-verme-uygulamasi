import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/Urun.dart';
import '../../providers/SepetSaglayici.dart';
import '../../providers/MenuSaglayici.dart';

class MenuEkrani extends StatelessWidget {
  const MenuEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuSaglayici>(
      builder: (context, menuProvider, child) {
        return DefaultTabController(
          length: menuProvider.kategoriler.length,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabs: menuProvider.kategoriler
                    .map((category) => Tab(text: category))
                    .toList(),
              ),
              Expanded(
                child: TabBarView(
                  children: menuProvider.kategoriler.map((category) {
                    final urunler = menuProvider.menuOgeleri[category] ?? [];
                    return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: urunler.length,
                      itemBuilder: (context, index) {
                        final urun = urunler[index];
                        final sepetProvider = context.watch<SepetSaglayici>();
                        final miktar = sepetProvider.elemanlar
                            .where((item) => item.urun.id == urun.id)
                            .fold(0, (sum, item) => sum + item.adet);

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: category == 'Yiyecekler'
                                  ? Colors.orange[100]
                                  : category == 'İçecekler'
                                      ? Colors.blue[100]
                                      : Colors.pink[100],
                              child: Icon(
                                category == 'Yiyecekler'
                                    ? Icons.fastfood
                                    : category == 'İçecekler'
                                        ? Icons.local_drink
                                        : Icons.cake,
                                color: category == 'Yiyecekler'
                                    ? Colors.orange
                                    : category == 'İçecekler'
                                        ? Colors.blue
                                        : Colors.pink,
                              ),
                            ),
                            title: Text(urun.ad),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(urun.aciklama),
                                Text(
                                  '${urun.fiyat} TL',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: miktar > 0
                                      ? () {
                                          sepetProvider.miktarAzalt(urun.id);
                                          if (miktar == 1) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    '${urun.ad} sepetten çıkarıldı'),
                                                duration:
                                                    const Duration(seconds: 1),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  color: miktar > 0 ? Colors.red : Colors.grey,
                                ),
                                Container(
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$miktar',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    if (miktar == 0) {
                                      sepetProvider.elemanEkle(urun);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('${urun.ad} sepete eklendi'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    } else {
                                      sepetProvider.miktarArttir(urun.id);
                                    }
                                  },
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
