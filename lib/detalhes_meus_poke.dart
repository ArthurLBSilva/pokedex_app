import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pokedex_app/api_pokemons/pokemons_api.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:pokedex_app/database/pokemon_database.dart';



class DetalhesMeusPoke extends StatelessWidget {
  final Pokemon pokemon;

  const DetalhesMeusPoke({Key? key, required this.pokemon}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.nomes['english'] ?? 'Detalhes do Pokémon'),
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
                cacheKey: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${_formatId(pokemon.id)}.png',
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
                        const SizedBox(height: 50),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog(context);
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
                            child: const Text("Soltar"),
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

  String _formatId(int id) {
    return id.toString().padLeft(3, '0');
  }

void _showConfirmationDialog(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.noHeader,
    showCloseIcon: false,
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    title: 'Atenção',
    desc: 'Você tem certeza que deseja soltar o Pokémon?',
    btnCancelOnPress: () {},
    btnOkOnPress: () async {
      await PokemonDatabase.instance.deleteCapturado(pokemon.id);
      Navigator.pop(context, true); // Retorna true após a exclusão para indicar que a lista deve ser atualizada
      // esse true ae é do meus pokemons para atualizar a lista
    },
    btnOkText: 'Sim',
    btnCancelText: 'Não',
  ).show();
}


}