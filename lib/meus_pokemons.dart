import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pokedex_app/api_pokemons/pokemons_api.dart';
import 'package:pokedex_app/database/pokemon_database.dart';
import 'package:pokedex_app/detalhes_meus_poke.dart';

class MeusPokemons extends StatefulWidget {
  const MeusPokemons({super.key});


  @override
  _MeusPokemonsState createState() => _MeusPokemonsState();
}

class _MeusPokemonsState extends State<MeusPokemons> {
  final PokemonDatabase _pokemonDatabase = PokemonDatabase.instance;
  List<Pokemon> _capturados = [];

  @override
  void initState() {
    super.initState();
    _carregarPokemonsCapturados();
  }

  Future<void> _carregarPokemonsCapturados() async {
    try {
      final capturados = await _pokemonDatabase.getCapturados(); // Obtém Pokémons do banco
      setState(() {
        _capturados = capturados.map((json) => json['pokemon'] as Pokemon).toList(); // Extrai apenas o Pokémon
      });
    } catch (e) {
      print('Erro ao carregar Pokémons capturados: $e');
    }
  }

  String _formatId(int id) {
    return id.toString().padLeft(3, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pokémons'),
        backgroundColor: const Color(0xFF526E93),
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: const Color(0xFF526E93),
        child: _capturados.isEmpty
            ? const Center(child: Text('Nenhum Pokémon capturado'))
            : ListView.builder(
                itemCount: _capturados.length,
                itemBuilder: (context, index) {
                  final pokemon = _capturados[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetalhesMeusPoke(pokemon: pokemon)),
                      ).then((shouldUpdate) {
                        if (shouldUpdate == true) {
                          // Aqui você atualiza a lista de Pokémon após a exclusão
                          _carregarPokemonsCapturados();
                        }
                      });
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      color: const Color(0xFFF8F8D6),
                      child: ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/sprites/${_formatId(pokemon.id)}MS.png',
                          cacheKey: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/sprites/${_formatId(pokemon.id)}MS.png',
                          height: 65,
                          width: 65,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                        title: Text(
                          pokemon.nomes['english'] ?? 'Nome não disponível',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Tipo: ${pokemon.type.join(', ')}',
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
