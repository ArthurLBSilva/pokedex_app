import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pokedex_app/api_pokemons/pokemons_api.dart';
import 'package:pokedex_app/detalhes_Poke.dart';
import 'package:pokedex_app/database/pokemon_database.dart';
import 'package:cached_network_image/cached_network_image.dart';

const int pageSize = 10;
class ListaPokemons extends StatefulWidget {
  const ListaPokemons({super.key});


  @override
  _ListaPokemonsState createState() => _ListaPokemonsState();
}

class _ListaPokemonsState extends State<ListaPokemons> {
  final PagingController<int, Pokemon> _pagingController = PagingController(firstPageKey: 0);
  final PokemonDatabase _pokemonDatabase = PokemonDatabase.instance;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPokemons(pageKey);
    });
  }

Future<void> _fetchPokemons(int pageKey) async {
  try {
    const int pageSize = 10;
    
    // Calcule `start` com base no pageKey
    int start = pageKey * pageSize;

    // Verifique se há cache de Pokémons disponível para essa página
    final cachedPokemons = await _pokemonDatabase.getPokemons(start, pageSize);

    if (cachedPokemons.length == pageSize) {
      // Adiciona Pokémons em cache ao controle de paginação
      final nextPageKey = pageKey + 1;
      _pagingController.appendPage(cachedPokemons, nextPageKey);
    } else {
      // Caso o cache não tenha a quantidade certa de Pokémons, faz a requisição online
      final response = await http.get(
        Uri.parse('https://bd13-177-20-136-241.ngrok-free.app/pokemons?_limit=$pageSize&_start=$start'),
      );

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> pokemonJsonList = json.decode(response.body);
        final List<Pokemon> newPokemons = pokemonJsonList.map((json) => Pokemon.fromJson(json)).toList();

        if (newPokemons.isEmpty) {
          // Se não houver mais Pokémons, define a página atual como a última
          _pagingController.appendLastPage([]);
        } else {
          // Insere os novos Pokémons no banco de dados e atualiza o controle
          await Future.wait(newPokemons.map((pokemon) => _pokemonDatabase.insertPokemon(pokemon)));

          // Verifica se a quantidade de Pokémons corresponde ao tamanho da página
          final isLastPage = newPokemons.length < pageSize;
          if (isLastPage) {
            _pagingController.appendLastPage(newPokemons);
          } else {
            final nextPageKey = pageKey + 1;
            _pagingController.appendPage(newPokemons, nextPageKey);
          }
        }
      } else {
        throw HttpException('Falha ao carregar Pokémons. Código de status: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Erro ao buscar Pokémons, usando cache local: $e');

    // Tenta carregar Pokémons do cache local novamente em caso de erro
    final cachedPokemons = await _pokemonDatabase.getPokemons(pageKey * pageSize, pageSize);
    if (cachedPokemons.isNotEmpty) {
      _pagingController.appendPage(cachedPokemons, pageKey + 1);
    } else {
      _pagingController.error = 'Não foi possível carregar dados, e o cache está vazio.';
    }
  }
}











  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  String _formatId(int id) {
    return id.toString().padLeft(3, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pokémons'),
        backgroundColor: const Color(0xFF526E93),
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: const Color(0xFF526E93),
        child: PagedListView<int, Pokemon>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Pokemon>(
            itemBuilder: (context, pokemon, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PokemonDetailPage(pokemon: pokemon),
                    ),
                  );
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
            noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Nenhum Pokémon encontrado')),
            firstPageErrorIndicatorBuilder: (context) => const Center(child: Text('Erro ao carregar Pokémons')),
          ),
        ),
      ),
    );
  }
}
