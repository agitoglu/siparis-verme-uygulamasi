import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/customer/MusteriAnaEkrani.dart';
import 'screens/admin/YoneticiAnaEkran.dart';
import 'providers/SepetSaglayici.dart';
import 'providers/MenuSaglayici.dart';
import 'providers/SiparisSaglayici.dart';
import 'providers/CalisanSaglayici.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/YoneticiSaglayici.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase başarıyla başlatıldı');

    // Admin koleksiyonunu oluştur
    final adminProvider = YoneticiSaglayici();
    await adminProvider.yoneticiKoleksiyonuOlustur();

    // Siparişleri yükle
    final orderProvider = SiparisSaglayici();
    await orderProvider.siparisleriYukle();

    if (orderProvider.masaSiparisler.isEmpty) {
      await orderProvider.varsayilanSiparisleriYukle();
    }
  } catch (e) {
    print('Firebase başlatma hatası: $e');
  }
  runApp(const SiparisUygulamasi());
}

class SiparisUygulamasi extends StatelessWidget {
  const SiparisUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => MenuSaglayici()..menuYukle(),
        ),
        ChangeNotifierProvider(create: (ctx) => SepetSaglayici()),
        ChangeNotifierProvider(
          create: (ctx) => SiparisSaglayici()..baslat(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CalisanSaglayici()..calisanlariYukle(),
        ),
        ChangeNotifierProvider(create: (ctx) => YoneticiSaglayici()),
      ],
      child: MaterialApp(
        title: 'Sipariş Uygulaması',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
        ),
        home: const GirisEkrani(),
      ),
    );
  }
}

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  void _showAdminLoginDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Column(
            children: [
              Icon(Icons.admin_panel_settings, size: 50, color: Colors.purple),
              SizedBox(height: 10),
              Text('Yönetici Girişi'),
            ],
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen şifre giriniz';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('İptal'),
            ),
            ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() => isLoading = true);

                        final isValid = await context
                            .read<YoneticiSaglayici>()
                            .sifreKontrol(passwordController.text);

                        if (mounted) {
                          if (isValid) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const YoneticiAnaEkran(),
                              ),
                            );
                          } else {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Hatalı şifre'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login),
              label: const Text('Giriş'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade100,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo veya İkon
                    Icon(
                      Icons.restaurant_menu,
                      size: 100,
                      color: Colors.purple.shade700,
                    ),
                    const SizedBox(height: 20),
                    // Başlık
                    Text(
                      'Restoran Sipariş Sistemi',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Giriş Butonları
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MusteriAnaEkrani(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person),
                      label: const Text('Müşteri Girişi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _showAdminLoginDialog(context),
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Yönetici Girişi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
