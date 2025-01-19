import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'MenuEkrani.dart';
import 'SepetEkrani.dart';
import 'FaturaEkrani.dart';
import 'GarsonDegerlendirEkrani.dart';
import '../../providers/SepetSaglayici.dart';
import '../../main.dart';

class MusteriAnaEkrani extends StatefulWidget {
  const MusteriAnaEkrani({super.key});

  @override
  State<MusteriAnaEkrani> createState() => _MusteriAnaEkraniState();
}

class _MusteriAnaEkraniState extends State<MusteriAnaEkrani> {
  int _seciliIndeks = 0;
  bool _masaSecildi = false;

  final List<Widget> _ekranlar = [
    const MenuEkrani(),
    const SepetEkrani(),
    const FaturaEkrani(),
    const GarsonDegerlendirEkrani(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SepetSaglayici>().baslat(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_masaSecildi) {
      return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const GirisEkrani(),
            ),
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Masa Seçimi'),
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final masaNumarasi = index + 1;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  context
                      .read<SepetSaglayici>()
                      .masaNumarasiAyarla(masaNumarasi);
                  setState(() {
                    _masaSecildi = true;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.table_bar, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Masa $masaNumarasi',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    final masaNumaras = context.watch<SepetSaglayici>().masaNumarasi;

    return WillPopScope(
      onWillPop: () async {
        if (_seciliIndeks > 0) {
          setState(() {
            _seciliIndeks--;
          });
          return false;
        }
        setState(() {
          _masaSecildi = false;
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Masa No: $masaNumaras'),
        ),
        body: _ekranlar[_seciliIndeks],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _seciliIndeks,
          onTap: (index) {
            setState(() {
              _seciliIndeks = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              activeIcon: Icon(Icons.menu_book_outlined),
              label: 'Menü',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              activeIcon: Icon(Icons.shopping_cart_outlined),
              label: 'Sepet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              activeIcon: Icon(Icons.receipt_outlined),
              label: 'Hesap',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              activeIcon: Icon(Icons.star_outline),
              label: 'Değerlendir',
            ),
          ],
        ),
      ),
    );
  }
}
