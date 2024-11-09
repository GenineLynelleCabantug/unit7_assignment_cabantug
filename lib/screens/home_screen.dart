import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';


class Wand {
  final String wood;
  final String core;
  final double length;

  Wand({
    required this.wood,
    required this.core,
    required this.length,
  });

  factory Wand.fromJson(Map<String, dynamic> json) {
    return Wand(
      wood: json['wood'] ?? 'Unknown Wood',
      core: json['core'] ?? 'Unknown Core',
      length: (json['length'] as num?)?.toDouble() ?? 0.0,
    );
  }
}


class HpStaff {
  final String name;
  final String gender;
  final String species;
  final String house;
  final String dateOfBirth;
  final Wand wand;
  final String? img;

  HpStaff({
    required this.name,
    required this.gender,
    required this.species,
    required this.house,
    required this.dateOfBirth,
    required this.wand,
    this.img,
  });

  factory HpStaff.fromJson(Map<String, dynamic> json) {
    return HpStaff(
      name: json['name'] ?? 'Unknown Name',
      gender: json['gender'] ?? 'Unknown Gender',
      species: json['species'] ?? 'Unknown Species',
      house: json['house'] ?? 'Unknown House',
      dateOfBirth: json['dateOfBirth'] ?? 'Unknown Date of Birth',
      wand: Wand.fromJson(json['wand'] ?? {}),
      img: json['image'] is String ? json['image'] : null,
    );
  }
}


class ApiResponse {
  final List<HpStaff> content;

  ApiResponse({
    required this.content,
  });

  factory ApiResponse.fromJson(List<dynamic> jsonList) {
    List<HpStaff> content = jsonList
        .map((json) => HpStaff.fromJson(json as Map<String, dynamic>))
        .toList();

    return ApiResponse(content: content);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ApiResponse> futureApiResponse;

  @override
  void initState() {
    super.initState();
    futureApiResponse = fetchHarryPotterStaff();
  }

  Future<ApiResponse> fetchHarryPotterStaff() async {
    final response = await http.get(
      Uri.parse('https://hp-api.onrender.com/api/characters/staff'),
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load API data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder<ApiResponse>(
        future: futureApiResponse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.content.length,
              itemBuilder: (context, index) {
                var characterStaff = snapshot.data!.content[index];

                final controller = ExpandedTileController();

                return ExpandedTile(
                  controller: controller,
                  title: Text(
                    characterStaff.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: characterStaff.img != null &&
                          characterStaff.img!.isNotEmpty
                      ? Image.network(
                          characterStaff.img!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: TextStyle(
                            fontSize: 25,
                            color: const Color.fromARGB(255, 6, 96, 170)),
                      ),
                      Text("Gender: ${characterStaff.gender.isNotEmpty ? characterStaff.gender : 'Unknown'}"),
                      Text("Species: ${characterStaff.species.isNotEmpty ? characterStaff.species : 'Unknown'}"),
                      Text("House: ${characterStaff.house.isNotEmpty ? characterStaff.house : 'Unknown'}"),
                      Text("Date of Birth: ${characterStaff.dateOfBirth.isNotEmpty ? characterStaff.dateOfBirth : 'Unknown'}"),
                      Text("Wand Wood: ${characterStaff.wand.wood.isNotEmpty ? characterStaff.wand.wood : 'Unknown'}"),
                      Text("Wand Core: ${characterStaff.wand.core.isNotEmpty ? characterStaff.wand.core : 'Unknown'}"),
                      Text("Wand Length: ${characterStaff.wand.length != 0.0 ? '${characterStaff.wand.length} cm' : 'Unknown'}"),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: HomeScreen()));
}
