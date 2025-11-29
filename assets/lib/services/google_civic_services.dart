import 'dart:convert';
import 'package:assets/config/config.dart';
import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; 


Future<List<dynamic>> fetchGoogleCivicEvents() async {
  const privateToken = ApiConfig.googleCivicApiKey; 
  
  try {
    if (kIsWeb) {
      print('Running on web - using API without location');
    } else {
      LocationPermission permission = await Geolocator.checkPermission(); 
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission(); 
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied'); 
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied'); 
      }

      Position position = await Geolocator.getCurrentPosition();
      final String latitude = position.latitude.toString(); 
      final String longitude = position.longitude.toString(); 
      print('Location: $latitude, $longitude');
    }

    final url = Uri.parse(
      "https://www.googleapis.com/civicinfo/v2/elections?key=AIzaSyCYMEUWK_lg5FnNzXl_L5nfvhii9oQd7H8", /* Remove "!@#" in after finished step*/ 
    );


    final response = await http.get(
      url,  
      headers: {
      'Authorization': 'Bearer $privateToken', 
      'Content-Type': 'application/json'
    });

    print(response.body);
    print('Request URL: $url');
    print('Headers: ${response.request?.headers}'); 
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); 
      print("Election Events and Data: $data['elections']"); 
    
      return data['elections'] ?? []; 
    } else {
      throw Exception('Failed to load events. Code: ${response.statusCode}'); 
    }
  } catch (e) {
    print('Error fetching events: $e');
    return [];
  }
  
}


class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState(); 
    loadEvents();
  }

  void loadEvents() async {
    final events = await fetchGoogleCivicEvents(); 
    setState(() {
      _events = events;
      _isLoading = false; 
      }
    );
  }

  @override
  Widget build(BuildContext context) { 
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); 
    }

    if (_events.isEmpty) {
      return const Center(child: Text('No events found near you.')); 
    }

    return SizedBox(
      height: 190, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal, 
        itemCount: _events.length,
        itemBuilder: (context, index) { 
          final event = _events[index];
          final name = event['name'] ?? 'Unnamed Event'; 
          final summary = event['summary'] ?? 'No summary'; 
          final imageUrl = event['logo']?['url'];
          final date = event['electionDay'] ?? 'Date not available';

          return Container(
            width: 260, 
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 16), 
            child: Card(
              elevation: 0,
              color: secondaryColor.withAlpha(40), 
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(name.toString()),
                      content: Text(date.toString()), 
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0,),
                      child:  CustomNormalText(
                        text:  name.toString(), 
                        color: proffessionalBlack, 
                        overflow: TextOverflow.ellipsis, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w500, 
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      child: CustomNormalText(
                        text: date.toString(), 
                        color: proffessionalBlack, 
                        overflow: TextOverflow.ellipsis, 
                        fontSize: 12, 
                        fontWeight: FontWeight.w400, 
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PoliticalEventsService {
  Future<List<Election>> getUpcomingElections() async {
    const privateToken = 'AIzaSyCYMEUWK_lg5FnNzXl_L5nfvhii9oQd7H8';  
    try {
      final response = await http.get(Uri.parse(
        'https://www.googleapis.com/civicinfo/v2/elections?key=$privateToken'
      ));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['elections'] as List).map((e) => Election.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching elections: $e');
    }
    return [];
  }
}

class Election {
  final String id;
  final String name;
  final String electionDay;
  final String? description;

  Election({required this.id, required this.name, required this.electionDay, this.description});

  factory Election.fromJson(Map<String, dynamic> json) {
    return Election(
      id: json['id'],
      name: json['name'],
      electionDay: json['electionDay'],
      description: json['ocdDivisionId'], 
    );
  }
}

class CongressSession {
  final String session;
  final DateTime startDate;
  final DateTime endDate;
  
  CongressSession({required this.session, required this.startDate, required this.endDate});
  
  factory CongressSession.fromJson(Map<String, dynamic> json) {
    return CongressSession(
      session: json['session'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}