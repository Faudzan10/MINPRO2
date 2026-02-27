import 'package:flutter/material.dart';

void main() {
  runApp(PetCareApp());
}

class PetCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetCare Shelter',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomePage(),
    );
  }
}

class Pet {
  String id;
  String kategori;
  String jenis;
  String warna;
  String lokasi;
  String kontak;

  Pet({
    required this.id,
    required this.kategori,
    required this.jenis,
    required this.warna,
    required this.lokasi,
    required this.kontak,
  });
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Pet> petList = [];
  int counter = 1;

  String generateId(String jenis) {
    String prefix = jenis.substring(0, 3).toUpperCase();
    return "$prefix${counter.toString().padLeft(3, '0')}";
  }

  void tambahPet(Pet pet) {
    setState(() {
      petList.add(pet);
      counter++;
    });
  }

  void updatePet(int index, Pet pet) {
    setState(() {
      petList[index] = pet;
    });
  }

  void hapusPet(int index) {
    setState(() {
      petList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PetCare Shelter 🐾"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: petList.isEmpty
          ? Center(
              child: Text(
                "Belum ada data hewan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            )
          : ListView.builder(
              itemCount: petList.length,
              itemBuilder: (context, index) {
                Pet pet = petList[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(Icons.pets, color: Colors.teal),
                    title: Text(
                      pet.jenis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "ID: ${pet.id}\nKategori: ${pet.kategori}\nWarna: ${pet.warna}\nLokasi: ${pet.lokasi}\nKontak: ${pet.kontak}",
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPetPage(
                            onAdd: (updatedPet) {
                              updatePet(index, updatedPet);
                            },
                            generateId: generateId,
                            existingPet: pet,
                          ),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        hapusPet(index);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddPetPage(onAdd: tambahPet, generateId: generateId),
            ),
          );
        },
      ),
    );
  }
}

class AddPetPage extends StatefulWidget {
  final Function(Pet) onAdd;
  final String Function(String) generateId;
  final Pet? existingPet;

  AddPetPage({required this.onAdd, required this.generateId, this.existingPet});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController warnaController = TextEditingController();
  TextEditingController lokasiController = TextEditingController();
  TextEditingController kontakController = TextEditingController();

  String selectedKategori = "Mamalia";
  String selectedJenis = "Anjing";

  Map<String, List<String>> kategoriMap = {
    "Mamalia": [
      "Anjing",
      "Kucing",
      "Kelinci",
      "Hamster",
      "Marmut",
      "Sugar Glider",
    ],
    "Reptil": ["Ular", "Iguana", "Kura-kura"],
    "Unggas": ["Ayam", "Bebek", "Burung"],
  };

  @override
  void initState() {
    super.initState();

    if (widget.existingPet != null) {
      selectedKategori = widget.existingPet!.kategori;
      selectedJenis = widget.existingPet!.jenis;
      warnaController.text = widget.existingPet!.warna;
      lokasiController.text = widget.existingPet!.lokasi;
      kontakController.text = widget.existingPet!.kontak;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.existingPet != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Hewan" : "Tambah Hewan"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField(
                value: selectedKategori,
                decoration: InputDecoration(
                  labelText: "Kategori Hewan",
                  border: OutlineInputBorder(),
                ),
                items: kategoriMap.keys.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedKategori = value.toString();
                    selectedJenis = kategoriMap[selectedKategori]!.first;
                  });
                },
              ),
              SizedBox(height: 15),
              DropdownButtonFormField(
                value: selectedJenis,
                decoration: InputDecoration(
                  labelText: "Jenis Hewan",
                  border: OutlineInputBorder(),
                ),
                items: kategoriMap[selectedKategori]!
                    .map(
                      (jenis) =>
                          DropdownMenuItem(value: jenis, child: Text(jenis)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedJenis = value.toString();
                  });
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: warnaController,
                decoration: InputDecoration(
                  labelText: "Warna",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Warna tidak boleh kosong" : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: lokasiController,
                decoration: InputDecoration(
                  labelText: "Lokasi Shelter",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Lokasi tidak boleh kosong" : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: kontakController,
                decoration: InputDecoration(
                  labelText: "Kontak",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Kontak tidak boleh kosong" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String idBaru = isEdit
                        ? widget.existingPet!.id
                        : widget.generateId(selectedJenis);

                    widget.onAdd(
                      Pet(
                        id: idBaru,
                        kategori: selectedKategori,
                        jenis: selectedJenis,
                        warna: warnaController.text,
                        lokasi: lokasiController.text,
                        kontak: kontakController.text,
                      ),
                    );

                    Navigator.pop(context);
                  }
                },
                child: Text(isEdit ? "Update" : "Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
