import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/MenuSaglayici.dart';
import '../../models/Urun.dart';

class MenuYonetimEkrani extends StatefulWidget {
  const MenuYonetimEkrani({super.key});

  @override
  State<MenuYonetimEkrani> createState() => _MenuYonetimEkraniState();
}

class _MenuYonetimEkraniState extends State<MenuYonetimEkrani>
    with TickerProviderStateMixin {
  late TabController _sekmeKontrolcusu;
  bool _yukleniyorMu = false;

  void _sekmeKontrolcusuGuncelle(List<String> kategoriler) {
    _sekmeKontrolcusu.dispose();
    _sekmeKontrolcusu = TabController(
      length: kategoriler.length,
      vsync: this,
    );
  }

  @override
  void initState() {
    super.initState();
    final menuSaglayici = Provider.of<MenuSaglayici>(context, listen: false);
    _sekmeKontrolcusu = TabController(
      length: menuSaglayici.kategoriler.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _sekmeKontrolcusu.dispose();
    super.dispose();
  }

  void _urunEkleDialogGoster(BuildContext context, String kategori) async {
    final adKontrolcusu = TextEditingController();
    final fiyatKontrolcusu = TextEditingController();
    final aciklamaKontrolcusu = TextEditingController();

    final mesajGonderici = ScaffoldMessenger.of(context);
    final yonlendirici = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text('Yeni $kategori Ekle'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: adKontrolcusu,
                    decoration: const InputDecoration(
                      labelText: 'Ürün Adı',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: fiyatKontrolcusu,
                    decoration: const InputDecoration(
                      labelText: 'Fiyat',
                      border: OutlineInputBorder(),
                      prefixText: '₺ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: aciklamaKontrolcusu,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _yukleniyorMu ? null : () => yonlendirici.pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: _yukleniyorMu
                  ? null
                  : () async {
                      if (adKontrolcusu.text.isEmpty) {
                        mesajGonderici.showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen ürün adı giriniz'),
                          ),
                        );
                        return;
                      }

                      final fiyat = double.tryParse(
                          fiyatKontrolcusu.text.replaceAll(',', '.'));
                      if (fiyat == null || fiyat <= 0) {
                        mesajGonderici.showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen geçerli bir fiyat giriniz'),
                          ),
                        );
                        return;
                      }

                      try {
                        setState(() => _yukleniyorMu = true);
                        yonlendirici.pop();

                        final yeniUrun = Urun(
                          id: '',
                          ad: adKontrolcusu.text.trim(),
                          fiyat: fiyat,
                          aciklama: aciklamaKontrolcusu.text.trim(),
                          kategori: kategori,
                        );

                        await context.read<MenuSaglayici>().urunEkle(yeniUrun);

                        if (!mounted) return;
                        mesajGonderici.showSnackBar(
                          SnackBar(
                            content: Text('${yeniUrun.ad} başarıyla eklendi'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        mesajGonderici.showSnackBar(
                          const SnackBar(
                            content: Text('Ürün eklenirken bir hata oluştu'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _yukleniyorMu = false);
                        }
                      }
                    },
              child: _yukleniyorMu
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _urunDuzenleDialogGoster(BuildContext context, Urun urun) {
    final adKontrolcusu = TextEditingController(text: urun.ad);
    final fiyatKontrolcusu = TextEditingController(text: urun.fiyat.toString());
    final aciklamaKontrolcusu = TextEditingController(text: urun.aciklama);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: adKontrolcusu,
                decoration: const InputDecoration(labelText: 'Ürün Adı'),
              ),
              TextField(
                controller: fiyatKontrolcusu,
                decoration: const InputDecoration(labelText: 'Fiyat'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: aciklamaKontrolcusu,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final fiyat = double.tryParse(fiyatKontrolcusu.text);
              if (adKontrolcusu.text.isNotEmpty && fiyat != null) {
                final guncellenmisUrun = Urun(
                  id: urun.id,
                  ad: adKontrolcusu.text,
                  fiyat: fiyat,
                  aciklama: aciklamaKontrolcusu.text,
                  kategori: urun.kategori,
                );
                context.read<MenuSaglayici>().urunGuncelle(guncellenmisUrun);
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuSaglayici>(
      builder: (context, menuSaglayici, child) {
        if (_sekmeKontrolcusu.length != menuSaglayici.kategoriler.length) {
          _sekmeKontrolcusuGuncelle(menuSaglayici.kategoriler);
        }

        if (_yukleniyorMu) {
          return const Center(child: CircularProgressIndicator());
        }

        if (menuSaglayici.kategoriler.isEmpty) {
          return const Center(
            child: Text('Henüz kategori bulunmamaktadır'),
          );
        }

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: TabBar(
              controller: _sekmeKontrolcusu,
              isScrollable: true,
              tabs: menuSaglayici.kategoriler
                  .map((category) => Tab(text: category))
                  .toList(),
            ),
          ),
          body: TabBarView(
            controller: _sekmeKontrolcusu,
            children: menuSaglayici.kategoriler.map((category) {
              final urunler = menuSaglayici.menuOgeleri[category] ?? [];
              return Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: urunler.length,
                    itemBuilder: (context, index) {
                      final urun = urunler[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              category == 'Yiyecekler'
                                  ? Icons.fastfood
                                  : category == 'İçecekler'
                                      ? Icons.local_drink
                                      : Icons.cake,
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
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _urunDuzenleDialogGoster(context, urun),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Ürünü Sil'),
                                      content: const Text(
                                          'Bu ürünü silmek istediğinize emin misiniz?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('İptal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            menuSaglayici.urunSil(
                                                category, urun.id);
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          child: const Text('Sil'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: () => _urunEkleDialogGoster(context, category),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
