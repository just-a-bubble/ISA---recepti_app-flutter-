import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../services/api_client.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService api = ApiService();
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController ipCtrl = TextEditingController(text: '192.168.');
  String msg = "";

  void login() async {
    final ip = ipCtrl.text.trim();

    if (ip.isEmpty) {
      setState(() => msg = "Vnesi IP naslov strežnika.");
      return;
    }

    await ApiClient.setBaseUrl(ip);

    final ok = await api.login(userCtrl.text, passCtrl.text);
    if (ok && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => msg = "Napačno uporabniško ime ali geslo.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Prijava",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: userCtrl,
                decoration:
                    const InputDecoration(labelText: "Uporabniško ime"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Geslo"),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  child: const Text("Prijava"),
                ),
              ),
              TextField(
                controller: ipCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "IP naslov strežnika",
                  hintText: "192.168.",
                ),
              ),
              const SizedBox(height: 10),
              if (msg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(msg, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Registriraj se"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
