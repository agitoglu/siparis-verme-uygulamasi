import 'package:flutter/material.dart';
import 'MasaSiparisleriEkrani.dart';
import 'MenuYonetimEkrani.dart';
import '../../main.dart';
import 'PersonelYonetimEkrani.dart';

class YoneticiAnaEkran extends StatefulWidget {
  const YoneticiAnaEkran({super.key});

  @override
  State<YoneticiAnaEkran> createState() => _YoneticiAnaEkranState();
}

class _YoneticiAnaEkranState extends State<YoneticiAnaEkran>
    with SingleTickerProviderStateMixin {
  late TabController _tabKontrol;

  @override
  void initState() {
    super.initState();
    _tabKontrol = TabController(length: 3, vsync: this);
    _tabKontrol.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabKontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabKontrol.index > 0) {
          // Eğer ilk sekmede değilsek, bir önceki sekmeye dön
          _tabKontrol.animateTo(_tabKontrol.index - 1);
          return false;
        } else {
          // İlk sekmedeyken giriş ekranına dön
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const GirisEkrani(),
            ),
          );
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yönetici Paneli'),
          bottom: TabBar(
            controller: _tabKontrol,
            tabs: const [
              Tab(text: 'Menü Yönetimi'),
              Tab(text: 'Masa Siparişleri'),
              Tab(text: 'Personel Yönetimi'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabKontrol,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            MenuYonetimEkrani(),
            MasaSiparisleriEkrani(),
            PersonelYonetimEkrani(),
          ],
        ),
      ),
    );
  }
}
