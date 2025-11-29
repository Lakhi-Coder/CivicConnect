import 'package:assets/services/AI_recom_services.dart';

class PoliticalEventsService {
  final AIRecommendationService _aiService = AIRecommendationService();

  Future<String> getWeeklyPoliticalSummary() async {
    return await _aiService.generatePoliticalEventsSummary();
  }

  Future<Map<String, dynamic>> getPoliticalEventsWithAnalysis() async {
    final summary = await getWeeklyPoliticalSummary();
    
    return {
      'summary': summary,
      'lastUpdated': DateTime.now(), 
      'source': 'AI Analysis',
    };
  }
}