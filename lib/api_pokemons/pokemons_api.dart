import 'dart:convert';

class Pokemon {
  final int id; 
  final Map<String, String> nomes;
  final List<String> type; 
  final Map<String, dynamic> atributos;

  Pokemon({
    required this.id,
    required this.nomes,
    required this.type,
    required this.atributos,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: int.tryParse(json['id'].toString()) ?? 0, // Convertendo o ID
      nomes: {
        'english': json['name']['english'] ?? 'Nome não disponível', // Tratamento para possíveis erros
        'japanese': json['name']['japanese'] ?? 'Nome não disponível',
        'chinese': json['name']['chinese'] ?? 'Nome não disponível',
        'french': json['name']['french'] ?? 'Nome não disponível',
      },
      type: List<String>.from(json['type'] ?? []), // Tratamento caso json['type'] não exista
      atributos: {
        'HP': json['base']['HP'],
        'Attack': json['base']['Attack'],
        'Defense': json['base']['Defense'],
        'Sp. Attack': json['base']['Sp. Attack'],
        'Sp. Defense': json['base']['Sp. Defense'],
        'Speed': json['base']['Speed'],
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': {
        'english': nomes['english'],
        'japanese': nomes['japanese'],
        'chinese': nomes['chinese'],
        'french': nomes['french'],
      },
      'type': type,
      'base': atributos,
    };
  }
}
