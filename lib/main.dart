import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://omzsotkkshclrpmytifl.supabase.co',
    anonKey: 'sb_publishable_ryqKnr0d4HwTwuSVxGj7FA_NpYINCb6',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: const Color(0xfff4f6fa),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),

      darkTheme: ThemeData.dark(),

      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      home: HomePage(isDark: isDark, toggleTheme: toggleTheme),
    );
  }
}

class HomePage extends StatelessWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const HomePage({super.key, required this.isDark, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PetCare Shelter"),
        centerTitle: true,
        actions: [
          Switch(
            value: isDark,
            onChanged: (value) {
              toggleTheme();
            },
          ),
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 80, color: Colors.blue),

              const SizedBox(height: 20),

              const Text(
                "Adopsi Hewan",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text(
                    "Tambah Hewan Adopsi",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FormPage()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.list),
                  label: const Text(
                    "Lihat Daftar Adopsi",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ListPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List pets = [];

  Future getPets() async {
    final data = await supabase.from('pets').select();

    setState(() {
      pets = data;
    });
  }

  Future deletePet(String id) async {
    await supabase.from('pets').delete().eq('id', id);

    getPets();
  }

  @override
  void initState() {
    super.initState();
    getPets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Adopsi")),

      body: pets.isEmpty
          ? const Center(child: Text("Belum ada data"))
          : ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.pets)),

                    title: Text(
                      pet['jenis'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      "Kategori: ${pet['kategori']}\n"
                      "Warna: ${pet['warna']}\n"
                      "Lokasi: ${pet['lokasi']}\n"
                      "Kontak: ${pet['kontak']}",
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FormPage(pet: pet),
                              ),
                            );

                            getPets();
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deletePet(pet['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class FormPage extends StatefulWidget {
  final Map? pet;

  const FormPage({super.key, this.pet});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  final kategori = TextEditingController();
  final jenis = TextEditingController();
  final warna = TextEditingController();
  final lokasi = TextEditingController();
  final kontak = TextEditingController();

  bool get isEdit => widget.pet != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      kategori.text = widget.pet!['kategori'];
      jenis.text = widget.pet!['jenis'];
      warna.text = widget.pet!['warna'];
      lokasi.text = widget.pet!['lokasi'];
      kontak.text = widget.pet!['kontak'];
    }
  }

  Future savePet() async {
    if (_formKey.currentState!.validate()) {
      if (isEdit) {
        await supabase
            .from('pets')
            .update({
              'kategori': kategori.text,
              'jenis': jenis.text,
              'warna': warna.text,
              'lokasi': lokasi.text,
              'kontak': kontak.text,
            })
            .eq('id', widget.pet!['id']);
      } else {
        await supabase.from('pets').insert({
          'kategori': kategori.text,
          'jenis': jenis.text,
          'warna': warna.text,
          'lokasi': lokasi.text,
          'kontak': kontak.text,
        });
      }

      Navigator.pop(context);
    }
  }

  Widget input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label tidak boleh kosong";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Hewan" : "Tambah Hewan")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              input("Kategori", kategori),
              input("Jenis", jenis),
              input("Warna", warna),
              input("Lokasi", lokasi),
              input("Kontak", kontak),

              const SizedBox(height: 10),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: savePet,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    isEdit ? "Update Data" : "Simpan Data",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
