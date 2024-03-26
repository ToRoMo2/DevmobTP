
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Stage v/d/p',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          color: Colors.brown[800], 
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> villes = [];
  List<String> departements = [];
  List<dynamic> pays = [];
  String? selectedVille;
  String? selectedDepartement;
  String? selectedPays;
  List<dynamic> entreprises = [];

  Future<void> fetchVilles() async {
    final response = await http.get(Uri.parse(
        'https://dptinfo.iutmetz.univ-lorraine.fr/applis/flutter_api_s4/api/getVilles.php'));
    if (response.statusCode == 200) {
      setState(() {
        villes = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<void> fetchPays() async {
    final response = await http.get(Uri.parse(
        'https://dptinfo.iutmetz.univ-lorraine.fr/applis/flutter_api_s4/api/getPays.php'));
    if (response.statusCode == 200) {
      setState(() {
        pays = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load countries');
    }
  }

  Future<void> fetchEntreprises() async {
    String url =
        'https://dptinfo.iutmetz.univ-lorraine.fr/applis/flutter_api_s4/api/getByVDP.php?';
    if (selectedVille != null) {
      url += 'ville=$selectedVille&';
    }
    if (selectedDepartement != null) {
      url += 'dpt=$selectedDepartement&';
    }
    if (selectedPays != null) {
      url += 'pays=$selectedPays';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData != null && jsonData['liste'] != null) {
        setState(() {
          entreprises = jsonData['liste'];
        });
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to load entreprises');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVilles();
    fetchPays();
    departements =
        List.generate(95, (index) => (index + 1).toString().padLeft(2, '0'));
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 480) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter stage v/d/p'),
        ),
        body: const Center(
          child: Text('La largeur de l\'écran est insuffisante'),
        ),
      );
    } else if (MediaQuery.of(context).size.height < 300) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter stage v/d/p'),
        ),
        body: const Center(
          child: Text('La Hauteur de l\'écran est insuffisante'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter stage v/d/p'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Critères',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  constraints: const BoxConstraints(
                      maxWidth: 300),
                  child: DropdownButton<String>(
                    value: selectedVille,
                    hint: const Text('Ville'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedVille = newValue;
                      });
                    },
                    items:
                        villes.map<DropdownMenuItem<String>>((dynamic value) {
                      return DropdownMenuItem<String>(
                        value: value['ville'],
                        child: Text(value['ville']),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  constraints: const BoxConstraints(
                      maxWidth: 300),
                  margin: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedDepartement,
                    hint: const Text('Département'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDepartement = newValue;
                      });
                    },
                    items: departements
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  constraints: const BoxConstraints(
                      maxWidth: 300),
                  child: DropdownButton<String>(
                    value: selectedPays,
                    hint: const Text('Pays'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPays = newValue;
                      });
                    },
                    items: pays.map<DropdownMenuItem<String>>((dynamic value) {
                      return DropdownMenuItem<String>(
                        value: value['pays'],
                        child: Text(value['pays']),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    fetchEntreprises();
                  },
                  child: const Text('Actualiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.orange.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Nombre d\'entreprises : ${entreprises.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.orange[100], 
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width < 1000 ? 3 : 5,
                  
                  crossAxisSpacing: 8.0, 
                  mainAxisSpacing: 2.0, 
                ),
                itemCount: entreprises.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.orange,
                                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                          
                            child: Text(
                              entreprises[index]['noment1'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white, 
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white), 
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  // Adresse de l'entreprise
                                  '${entreprises[index]['adr1']}\n${entreprises[index]['adr2']}\n${entreprises[index]['cpent']} ${entreprises[index]['ville']} ${entreprises[index]['pays']}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black, // Texte en noir
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

