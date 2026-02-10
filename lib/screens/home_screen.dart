import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();

  String username = "";
  List favourites = [];
  List received = [];
  List searchResults = [];

  Map<String, dynamic>? openedRecipe; // <- enako kot fav-display

  final TextEditingController searchCtrl = TextEditingController();

  bool loading = true;
  String error = "";

  bool isFavourite(int recipeId) {
    return favourites.any((f) => f['id'] == recipeId);
  }

  void openImage(String base64Image) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(100), // ← KLJUČNO
              clipBehavior: Clip.none,
              minScale: 1,
              maxScale: 5,
              child: Image.memory(
                base64Decode(base64Image.split(',').last),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }



  @override
  void initState() {
    super.initState();
    loadMe();
  }

  Future<void> loadMe() async {
    try {
      final data = await api.me();
      setState(() {
        username = data['username'];
        favourites = data['favourites'];
        received = data['received'];
        loading = false;
      });
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> showRecipe(int id) async {
    try {
      final recipe = await api.getRecipe(id);
      setState(() => openedRecipe = recipe);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Napaka pri nalaganju recepta.")),
      );
    }
  }

  void closeRecipe() {
    setState(() => openedRecipe = null);
  }

  Future<void> search() async {
    final q = searchCtrl.text.trim();
    if (q.isEmpty) return;

    try {
      final res = await api.search(q);
      setState(() {
        searchResults = res;
        error = "";
      });
    } catch (_) {
      setState(() => error = "Napaka pri iskanju.");
    }
  }

  Future<void> addFavourite(dynamic r) async {
    await api.addFavourite(r['id']);
    setState(() {
      favourites.add({'id': r['id'], 'naziv': r['naziv']});
    });
  }

  Future<void> removeFavourite(int id) async {
    await api.removeFavourite(id);
    setState(() {
      favourites.removeWhere((f) => f['id'] == id);
      if (openedRecipe != null && openedRecipe!['id'] == id) {
        openedRecipe = null;
      }
    });
  }

  Future<void> shareRecipe(int id) async {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Deli recept"),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(labelText: "Uporabniško ime"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Prekliči"),
          ),
          ElevatedButton(
            onPressed: () async {
              await api.share(id, ctrl.text);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Pošlji"),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    await api.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Widget recipeImage(String img) {
    if (img.isEmpty) return const SizedBox();
      return GestureDetector(
      onTap: () => openImage(img),
      child: Image.memory(
        base64Decode(img.split(',').last),
        height: 220,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget card(Widget child) => Container(
        width: 360,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6)
          ],
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Iskanje receptov"),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout))
        ],
      ),
      backgroundColor: const Color(0xfff5f5f5),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text("Pozdravljen, $username!",
                  style: const TextStyle(fontSize: 18)),

              const SizedBox(height: 16),

              /// ====== NAJUBJŠI ======
              card(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tvoji najljubši recepti:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...favourites.map((f) => Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => showRecipe(f['id']),
                            child: Text(
                              f['naziv'],
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration:
                                    TextDecoration.underline,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () =>
                                removeFavourite(f['id']),
                          )
                        ],
                      ))
                ],
              )),

              const SizedBox(height: 16),

              /// ====== PREJETI ======
              card(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Prejeti recepti:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...received.map((r) => GestureDetector(
                        onTap: () => showRecipe(r['id']),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "${r['naziv']} (od ${r['sender']})",
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration:
                                  TextDecoration.underline,
                            ),
                          ),
                        ),
                      )),
                ],
              )),

              const SizedBox(height: 16),

              /// ====== PRIKAZ IZBRANEGA RECEPTA ======
              if (openedRecipe != null)
                card(Stack(
                  children: [
                    Column(
                      children: [
                        Text(
                          openedRecipe!['naziv'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        recipeImage(openedRecipe!['image']),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.red),
                        onPressed: closeRecipe,
                      ),
                    )
                  ],
                )),

              const SizedBox(height: 16),

              /// ====== ISKANJE ======
              card(Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      labelText: "Vnesi iskane besede",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: search,
                          child: const Text("Išči")),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          searchCtrl.clear();
                          setState(() => searchResults = []);
                        },
                        child: const Text("Počisti"),
                      )
                    ],
                  )
                ],
              )),

              const SizedBox(height: 16),

              if (error.isNotEmpty)
                Text(error,
                    style: const TextStyle(color: Colors.red)),

              /// ====== REZULTATI ISKANJA ======
              ...searchResults.map((r) => Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(r['naziv'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          recipeImage(r['image']),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              isFavourite(r['id'])
                                ? const Icon(Icons.check, color: Colors.green)
                                : ElevatedButton(
                                    onPressed: () => addFavourite(r),
                                    child: const Text("Najljubši"),
                                  ),
                              OutlinedButton(
                                onPressed: () =>
                                    shareRecipe(r['id']),
                                child: const Text("Deli"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
