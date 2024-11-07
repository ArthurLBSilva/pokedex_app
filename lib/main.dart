import 'package:flutter/material.dart';
import 'package:pokedex_app/encontro_diario.dart';
import 'package:pokedex_app/meus_pokemons.dart';
import 'package:pokedex_app/pokedex.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeMaterial(),
    );
  }
}

class HomeMaterial extends StatefulWidget {
  const HomeMaterial({super.key});

  @override
  State<HomeMaterial> createState() => _HomeMaterialState();
}

class _HomeMaterialState extends State<HomeMaterial> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/teste_img.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  height: 60, 
                  child: ElevatedButton(
                    onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ListaPokemons()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8F8D6), 
                      foregroundColor: const Color.fromARGB(221, 0, 0, 0),            
                      textStyle: const TextStyle(
                        fontSize: 20,                          
                        fontWeight: FontWeight.bold,
                      ),
                      side: const BorderSide(
                        color: Colors.black, 
                        width: 1,           
                      ),
                    ),
                    child: const Text("Pokédex"),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EncontroDiario()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8F8D6), 
                      foregroundColor: const Color.fromARGB(221, 0, 0, 0), 
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      side: const BorderSide(
                        color: Colors.black,
                        width: 1,         
                      ),
                    ),
                    child: const Text("Encontro Diário"),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MeusPokemons()),
                      );                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8F8D6),
                      foregroundColor: const Color.fromARGB(221, 0, 0, 0), 
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      side: const BorderSide(
                        color: Colors.black, 
                        width: 1,           
                      ),
                    ),
                    child: const Text("Meus Pokémon"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
