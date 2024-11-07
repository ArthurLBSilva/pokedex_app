import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:pokedex_app/api_pokemons/pokemons_api.dart';
import 'package:pokedex_app/database/pokemon_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';


bool capturado = false;
bool limite = false;

int gerarNumeroAleatorio(int min, int max) {
  final random = Random();
  return min + random.nextInt(max - min);
}

class EncontroDiario extends StatefulWidget {
  const EncontroDiario({super.key});

  @override
  _EncontroDiarioState createState() => _EncontroDiarioState();
}

class _EncontroDiarioState extends State<EncontroDiario> {
  late final PokemonDatabase _pokemonDatabase;
  Map<String, dynamic>? pokemonDiario;

  @override
  void initState() {
    super.initState();
    _pokemonDatabase = PokemonDatabase.instance;
    _verificarOuAtualizarPokemonDiario();
    _verificarLimiteCapturas();
  }

  Future<void> _verificarOuAtualizarPokemonDiario() async {
    try {
      final pokemonData = await _pokemonDatabase.getPokemonDiario();

      //DateTime.now().day
      if (pokemonData == null || pokemonData['dia'] != DateTime.now().day) {
        // Sorteia um novo Pokémon e insere/atualiza no banco
        capturado = false;
        final int idAleatorio = gerarNumeroAleatorio(1, 809);
        final response = await http.get(
          Uri.parse('https://bd13-177-20-136-241.ngrok-free.app/pokemons/$idAleatorio'),
        );

        if (response.statusCode == HttpStatus.ok) {
          final pokemonJson = json.decode(response.body);
          final Pokemon pokemonAleatorio = Pokemon.fromJson(pokemonJson);

          // Atualiza ou insere o Pokémon diário no banco
          if (pokemonData == null) {
            await _pokemonDatabase.insertPokemonDiario(pokemonAleatorio, DateTime.now().day);
          } else {
            await _pokemonDatabase.updatePokemonDiario(pokemonAleatorio, DateTime.now().day);
          }

          setState(() {
            pokemonDiario = {'pokemon': pokemonAleatorio, 'dia': DateTime.now().day};
          });
          print('Pokémon diário atualizado: ${pokemonAleatorio.nomes['english']}');
        } else {
          throw HttpException('Falha ao carregar o Pokémon da API. Status: ${response.statusCode}');
        }
      } else {
        setState(() {
          pokemonDiario = pokemonData;
        });
        print('Pokémon diário já está atualizado para hoje: ${pokemonData['pokemon'].nomes['english']}');
      }
    } catch (e) {
      print('Erro ao buscar Pokémon diário: $e');
      _usarCacheLocal();
    }
  }

  // Caso ocorra um erro, utiliza o cache local
  Future<void> _usarCacheLocal() async {
    final cachedPokemon = await _pokemonDatabase.getPokemons(1, 1); // Obtém um Pokémon do cache
    if (cachedPokemon.isNotEmpty) {
      setState(() {
        pokemonDiario = {'pokemon': cachedPokemon.first, 'dia': DateTime.now().day};
      });
      print('Usando Pokémon do cache local: ${cachedPokemon.first.nomes['english']}');
    } else {
      print('Não foi possível carregar dados e o cache está vazio.');
    }
  }

Future<void> _verificarLimiteCapturas() async {
  final capturados = await _pokemonDatabase.getCapturados();
  setState(() {
    limite = capturados.length >= 6;
  });
}

Future<void> _salvarCapturado(Pokemon pokemon) async {
  final capturados = await _pokemonDatabase.getCapturados();

  if (capturados.length >= 6) {
    print('Limite de pokémons capturados atingido. Exclua um para capturar outro.');
    setState(() {
      limite = true;
    });
  } else {
    await _pokemonDatabase.insertCapturado(pokemon);
    setState(() {
      capturado = true;
      limite = false;
    });
  }
}


  String _formatId(int id) {
    return id.toString().padLeft(3, '0');
  }

  @override
  Widget build(BuildContext context) {
    if (pokemonDiario == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Encontro Diário'),
          backgroundColor: const Color(0xFF526E93),
          foregroundColor: Colors.black,
        ),
        body: const Center(child: CircularProgressIndicator()), // Exibe um indicador de carregamento
      );
    }

    final pokemon = pokemonDiario!['pokemon'];
    bool botaoDesabilitado = capturado || limite;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encontro Diário'),
        backgroundColor: const Color(0xFF526E93),
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: const Color(0xFF526E93),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${_formatId(pokemon.id)}.png',
                height: 150,
                width: 150,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              const SizedBox(height: 20),
            SizedBox(
              width: 390,
              child: Card(
                color: const Color(0xFFF8F8D6),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        pokemon.nomes['english'] ?? 'Nome não disponível',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tipo: ${pokemon.type.join(', ')}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Estatísticas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('HP:', style: TextStyle(fontSize: 18)),
                          Text(
                            '${pokemon.atributos['HP']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Defesa:', style: TextStyle(fontSize: 18)),
                          Text(
                            '${pokemon.atributos['Defense']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ataque:', style: TextStyle(fontSize: 18)),
                          Text(
                            '${pokemon.atributos['Attack']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Defesa Especial:', style: TextStyle(fontSize: 18)),
                          Text(
                            '${pokemon.atributos['Sp. Defense']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ataque Especial:', style: TextStyle(fontSize: 18)),
                          Text(
                            '${pokemon.atributos['Sp. Attack']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Velocidade:', style: TextStyle(fontSize: 18)),
                          Text(
                            '${pokemon.atributos['Speed']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                    Center(
                      child: botaoDesabilitado
                          ? const Card(
                              color: Color(0xFFF8F8D6),
                              elevation: 4,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    'Não disponível',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                await _salvarCapturado(pokemon);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF526E93),
                                foregroundColor: const Color.fromARGB(221, 255, 255, 255),
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                side: const BorderSide(
                                  color: Color.fromARGB(122, 0, 0, 0),
                                  width: 1,
                                ),
                              ),
                              child: const Text("Capturar"),
                            ),
                      ),
                    ],
                  ),
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
