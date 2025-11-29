import 'dart:convert';
import 'package:assets/config/config.dart';
import 'package:http/http.dart' as http;

class BillsService {
  static const String _apiKey = ApiConfig.congressApiKey; 
  static const String _baseUrl = 'https://api.congress.gov/v3';

  Future<List<Bill>> fetchRecentBills({int limit = 10}) async {
    try {
      print('Fetching recent bills from Congress.gov...');
      
      final response = await http.get(Uri.parse(
        '$_baseUrl/bill?api_key=$_apiKey&format=json&limit=$limit&sort=updateDate+desc'
      ));

      print('Congress.gov API Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bills = data['bills'] as List?;
        
        if (bills != null) {
          print('Successfully fetched ${bills.length} bills');
          return bills.map((billJson) => Bill.fromJson(billJson)).toList(); 
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching bills from Congress.gov: $e');
    }
    
    return [];
  }

  Future<List<Bill>> fetchBillsByStatus(String status, {int limit = 10}) async {
    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl/bill?api_key=$_apiKey&format=json&limit=$limit&sort=updateDate+desc'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bills = data['bills'] as List?;
        
        if (bills != null) {
          return bills.map((billJson) => Bill.fromJson(billJson))
            .where((bill) => bill.latestAction?.toLowerCase().contains(status.toLowerCase()) ?? false)
            .toList();
        }
      }
    } catch (e) {
      print('Error fetching bills by status: $e');
    }
    
    return [];
  }
}

class Bill {
  final String number;
  final String title;
  final String? latestAction;
  final String? updateDate;
  final String? introducedDate;
  final String? congress;
  final String? billType;
  final String? billUrl;

  Bill({
    required this.number,
    required this.title,
    this.latestAction,
    this.updateDate,
    this.introducedDate,
    this.congress,
    this.billType,
    this.billUrl,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      number: json['number']?.toString() ?? 'Unknown',
      title: json['title']?.toString() ?? 'No title available',
      latestAction: json['latestAction']?.toString(),
      updateDate: json['updateDate']?.toString(),
      introducedDate: json['introducedDate']?.toString(),
      congress: json['congress']?.toString(),
      billType: json['type']?.toString(),
      billUrl: json['url']?.toString(),
    );
  }

  String get displayTitle {
    return '$number: ${_truncateTitle(title)}';
  }

  String _truncateTitle(String title) {
    const maxLength = 80;
    if (title.length <= maxLength) return title;
    return '${title.substring(0, maxLength)}...'; 
  }

  String get status {
    final action = latestAction?.toLowerCase() ?? '';
    if (action.contains('became public law')) return 'Enacted';
    if (action.contains('passed house')) return 'Passed House';
    if (action.contains('passed senate')) return 'Passed Senate';
    if (action.contains('introduced')) return 'Introduced';
    return 'In Progress';
  }

  String get formattedDate {
    if (updateDate == null) return 'Date unknown';
    try {
      final date = DateTime.parse(updateDate!);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return updateDate!;
    }
  }

  DateTime? get date {
    if (updateDate == null) return null;
    try {
      return DateTime.parse(updateDate!);
    } catch (e) {
      return null;
    }
  }
}