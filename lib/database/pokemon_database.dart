import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pokedex_app/api_pokemons/pokemons_api.dart';
import 'dart:convert';


class PokemonDatabase {
  static final PokemonDatabase instance = PokemonDatabase._init();
  static Database? _database;

  PokemonDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pokemons.db');
    return _database!;
  }


  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pokemons (
        id INTEGER PRIMARY KEY,
        english_name TEXT,
        japanese_name TEXT,
        chinese_name TEXT,
        french_name TEXT,
        type TEXT,
        hp INTEGER,
        attack INTEGER,
        defense INTEGER,
        sp_attack INTEGER,
        sp_defense INTEGER,
        speed INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE pokemonDiario (
        id INTEGER PRIMARY KEY,
        english_name TEXT,
        japanese_name TEXT,
        chinese_name TEXT,
        french_name TEXT,
        type TEXT,
        hp INTEGER,
        attack INTEGER,
        defense INTEGER,
        sp_attack INTEGER,
        sp_defense INTEGER,
        speed INTEGER,
        dia INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE capturados (
        id INTEGER PRIMARY KEY,
        english_name TEXT,
        japanese_name TEXT,
        chinese_name TEXT,
        french_name TEXT,
        type TEXT,
        hp INTEGER,
        attack INTEGER,
        defense INTEGER,
        sp_attack INTEGER,
        sp_defense INTEGER,
        speed INTEGER
      )
    ''');
  }

  Future<void> insertPokemon(Pokemon pokemon) async {
    final db = await instance.database;
    await db.insert(
      'pokemons',
      {
        'id': pokemon.id,
        'english_name': pokemon.nomes['english'],
        'japanese_name': pokemon.nomes['japanese'],
        'chinese_name': pokemon.nomes['chinese'],
        'french_name': pokemon.nomes['french'],
        'type': jsonEncode(pokemon.type),
        'hp': pokemon.atributos['HP'],
        'attack': pokemon.atributos['Attack'],
        'defense': pokemon.atributos['Defense'],
        'sp_attack': pokemon.atributos['Sp. Attack'],
        'sp_defense': pokemon.atributos['Sp. Defense'],
        'speed': pokemon.atributos['Speed'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPokemonDiario(Pokemon pokemon, int agora) async {
    final db = await instance.database;
    await db.insert(
      'pokemonDiario',
      {
        'id': pokemon.id,
        'english_name': pokemon.nomes['english'],
        'japanese_name': pokemon.nomes['japanese'],
        'chinese_name': pokemon.nomes['chinese'],
        'french_name': pokemon.nomes['french'],
        'type': jsonEncode(pokemon.type),
        'hp': pokemon.atributos['HP'],
        'attack': pokemon.atributos['Attack'],
        'defense': pokemon.atributos['Defense'],
        'sp_attack': pokemon.atributos['Sp. Attack'],
        'sp_defense': pokemon.atributos['Sp. Defense'],
        'speed': pokemon.atributos['Speed'],
        'dia': agora,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertCapturado(Pokemon pokemon) async {
    final db = await instance.database;
    await db.insert(
      'capturados',
      {
        'id': pokemon.id,
        'english_name': pokemon.nomes['english'],
        'japanese_name': pokemon.nomes['japanese'],
        'chinese_name': pokemon.nomes['chinese'],
        'french_name': pokemon.nomes['french'],
        'type': jsonEncode(pokemon.type),
        'hp': pokemon.atributos['HP'],
        'attack': pokemon.atributos['Attack'],
        'defense': pokemon.atributos['Defense'],
        'sp_attack': pokemon.atributos['Sp. Attack'],
        'sp_defense': pokemon.atributos['Sp. Defense'],
        'speed': pokemon.atributos['Speed'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


Future<List<Pokemon>> getPokemons(int startId, int limit) async {
  final db = await instance.database;
  final result = await db.query(
    'pokemons',
    orderBy: 'id ASC',  // Garante que os Pokémons serão ordenados pelo ID
    limit: limit,
    offset: startId, 
  );

  return result.map((json) {
    return Pokemon(
      id: json['id'] as int,
      nomes: {
        'english': json['english_name'] as String,
        'japanese': json['japanese_name'] as String,
        'chinese': json['chinese_name'] as String,
        'french': json['french_name'] as String,
      },
      type: List<String>.from(jsonDecode(json['type'] as String)),
      atributos: {
        'HP': json['hp'] as int,
        'Attack': json['attack'] as int,
        'Defense': json['defense'] as int,
        'Sp. Attack': json['sp_attack'] as int,
        'Sp. Defense': json['sp_defense'] as int,
        'Speed': json['speed'] as int,
      },
    );
  }).toList();
}



Future<Map<String, dynamic>?> getPokemonDiario() async {
  final db = await instance.database;
  
  // Consulta sem `where` para obter o único Pokémon na tabela
  final List<Map<String, dynamic>> result = await db.query('pokemonDiario');

  // Verifica se a tabela tem algum registro
  if (result.isNotEmpty) {
    final json = result.first; // Obtemos o primeiro item

    // Cria o objeto Pokemon
    final pokemon = Pokemon(
      id: json['id'] as int,
      nomes: {
        'english': json['english_name'] as String,
        'japanese': json['japanese_name'] as String,
        'chinese': json['chinese_name'] as String,
        'french': json['french_name'] as String,
      },
      type: List<String>.from(jsonDecode(json['type'] as String)),
      atributos: {
        'HP': json['hp'] as int,
        'Attack': json['attack'] as int,
        'Defense': json['defense'] as int,
        'Sp. Attack': json['sp_attack'] as int,
        'Sp. Defense': json['sp_defense'] as int,
        'Speed': json['speed'] as int,
      },
    );

    // Retorna o Pokémon e o dia em um Map
    return {
      'pokemon': pokemon,
      'dia': json['dia'] as int, // Adiciona o valor do dia
    };
  } else {
    return null; // Retorna null se a tabela estiver vazia
  }
}

Future<List<Map<String, dynamic>>> getCapturados() async {
  final db = await instance.database;
  
  final result = await db.query(
    'capturados',
    limit: 6,  
  );

  return result.map((json) {
    return {
      'pokemon': Pokemon(
        id: json['id'] as int,
        nomes: {
          'english': json['english_name'] as String,
          'japanese': json['japanese_name'] as String,
          'chinese': json['chinese_name'] as String,
          'french': json['french_name'] as String,
        },
        type: List<String>.from(jsonDecode(json['type'] as String)),
        atributos: {
          'HP': json['hp'] as int,
          'Attack': json['attack'] as int,
          'Defense': json['defense'] as int,
          'Sp. Attack': json['sp_attack'] as int,
          'Sp. Defense': json['sp_defense'] as int,
          'Speed': json['speed'] as int,
        },
      ),
    };
  }).toList();
}


Future<void> deleteCapturado(int id) async {
  final db = await instance.database;
  
  // Deleta o Pokémon da tabela `capturados` onde o `id` corresponde ao fornecido
  await db.delete(
    'capturados',
    where: 'id = ?',
    whereArgs: [id],
  );
}



Future<void> updatePokemonDiario(Pokemon pokemon, int dia) async {
    final db = await instance.database;
    await db.update(
      'pokemonDiario',
      {
        'id': pokemon.id,
        'english_name': pokemon.nomes['english'],
        'japanese_name': pokemon.nomes['japanese'],
        'chinese_name': pokemon.nomes['chinese'],
        'french_name': pokemon.nomes['french'],
        'type': jsonEncode(pokemon.type),
        'hp': pokemon.atributos['HP'],
        'attack': pokemon.atributos['Attack'],
        'defense': pokemon.atributos['Defense'],
        'sp_attack': pokemon.atributos['Sp. Attack'],
        'sp_defense': pokemon.atributos['Sp. Defense'],
        'speed': pokemon.atributos['Speed'],
        'dia': dia,
      },
      where: 'id = ?',
      whereArgs: [pokemon.id],
    );
  }




  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
