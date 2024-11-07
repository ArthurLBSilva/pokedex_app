import 'package:flutter/material.dart';
import 'package:pokedex_app/api_pokemons/pokemons_api.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PokemonDetailPage extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailPage({Key? key, required this.pokemon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.nomes['english'] ?? 'Detalhes do Pokémon'),
        backgroundColor: const Color(0xFF526E93),
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: const Color(0xFF526E93), // Cor de fundo da tela
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // O card ocupa apenas o espaço necessário
            children: [
              CachedNetworkImage(
                imageUrl: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${_formatId(pokemon.id)}.png',
                cacheKey: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${_formatId(pokemon.id)}.png',
                height: 150,
                width: 150,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              const SizedBox(height: 20), // Espaço entre a imagem e o card
              
              SizedBox(
                width: 390,
              child: Card(
                color: const Color(0xFFF8F8D6), // Cor do card
                elevation: 4, // Sombra do card
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Espaçamento interno do card
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
                      // Espaço entre as estatísticas e o valor
                      const SizedBox(height: 10),
                      // Usando Row para alinhar "HP" e o valor
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaçamento entre os elementos
                        children: [
                          const Text(
                            'HP:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${pokemon.atributos['HP']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                     const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaçamento entre os elementos
                        children: [
                          const Text(
                            'Defesa:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${pokemon.atributos['Defense']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaçamento entre os elementos
                        children: [
                          const Text(
                            'Ataque:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${pokemon.atributos['Attack']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaçamento entre os elementos
                        children: [
                          const Text(
                            'Defesa especial:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${pokemon.atributos['Sp. Defense']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),                                                                  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaçamento entre os elementos
                        children: [
                          const Text(
                            'Ataque especial:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${pokemon.atributos['Sp. Attack']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaçamento entre os elementos
                        children: [
                          const Text(
                            'Velocidade:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${pokemon.atributos['Speed']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),  
                      const SizedBox(height: 50),                                          // Aqui você pode adicionar mais informações sobre o Pokémon
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

  String _formatId(int id) {
    return id.toString().padLeft(3, '0');
  }
}
