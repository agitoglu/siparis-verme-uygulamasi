import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/calisan.dart';
import '../../providers/CalisanSaglayici.dart';

class PersonelYonetimEkrani extends StatelessWidget {
  const PersonelYonetimEkrani({super.key});

  void _personelEkleDialog(BuildContext context) {
    final isimKontrol = TextEditingController();
    final telefonKontrol = TextEditingController();
    final gorevKontrol = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Personel Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: isimKontrol,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZğĞıİöÖşŞüÜçÇ\s]'),
                  ),
                ],
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: telefonKontrol,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gorevKontrol,
                decoration: const InputDecoration(
                  labelText: 'Görevi',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZğĞıİöÖşŞüÜçÇ\s]'),
                  ),
                ],
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
              if (isimKontrol.text.isEmpty ||
                  telefonKontrol.text.isEmpty ||
                  gorevKontrol.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tüm alanları doldurunuz')),
                );
                return;
              }

              final yeniPersonel = Calisan(
                id: DateTime.now().toString(),
                ad: isimKontrol.text.trim(),
                telefon: telefonKontrol.text.trim(),
                rol: gorevKontrol.text.trim(),
                baslangicTarihi: DateTime.now(),
              );

              context.read<CalisanSaglayici>().calisanEkle(yeniPersonel);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${yeniPersonel.ad} başarıyla eklendi'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _personelDuzenleDialog(BuildContext context, Calisan personel) {
    final isimKontrol = TextEditingController(text: personel.ad);
    final telefonKontrol = TextEditingController(text: personel.telefon);
    final gorevKontrol = TextEditingController(text: personel.rol);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personel Bilgilerini Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: isimKontrol,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZğĞıİöÖşŞüÜçÇ\s]'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: telefonKontrol,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gorevKontrol,
                decoration: const InputDecoration(
                  labelText: 'Görevi',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZğĞıİöÖşŞüÜçÇ\s]'),
                  ),
                ],
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
              if (isimKontrol.text.isEmpty ||
                  telefonKontrol.text.isEmpty ||
                  gorevKontrol.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tüm alanları doldurunuz')),
                );
                return;
              }

              final guncellenenPersonel = Calisan(
                id: personel.id,
                ad: isimKontrol.text.trim(),
                telefon: telefonKontrol.text.trim(),
                rol: gorevKontrol.text.trim(),
                baslangicTarihi: personel.baslangicTarihi,
                aktifMi: personel.aktifMi,
              );

              context
                  .read<CalisanSaglayici>()
                  .calisanGuncelle(guncellenenPersonel);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${guncellenenPersonel.ad} bilgileri güncellendi'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CalisanSaglayici>(
        builder: (context, personelSaglayici, child) {
          final personeller = personelSaglayici.calisanlar;

          if (personeller.isEmpty) {
            return const Center(
              child: Text(
                'Henüz personel eklenmemiş',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: personeller.length,
            itemBuilder: (context, index) {
              final personel = personeller[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: personel.aktifMi
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    child: Icon(
                      personel.aktifMi ? Icons.person : Icons.person_off,
                      color: personel.aktifMi ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    personel.ad,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: personel.aktifMi ? Colors.black : Colors.grey,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Görevi: ${personel.rol}'),
                      Text('Tel: ${personel.telefon}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Switch(
                            value: personel.aktifMi,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              personelSaglayici
                                  .calisanDurumDegistir(personel.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${personel.ad} ${value ? 'aktif' : 'pasif'} duruma getirildi',
                                  ),
                                  backgroundColor:
                                      value ? Colors.green : Colors.orange,
                                ),
                              );
                            },
                          ),
                          Text(
                            personel.aktifMi ? 'Aktif' : 'Pasif',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  personel.aktifMi ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _personelDuzenleDialog(context, personel),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Personeli Sil'),
                              content: Text(
                                '${personel.ad} personelini silmek istediğinize emin misiniz?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('İptal'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    personelSaglayici.calisanSil(personel.id);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${personel.ad} silindi'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _personelEkleDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
