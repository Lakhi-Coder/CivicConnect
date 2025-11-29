import 'package:flutter/material.dart';
import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:assets/services/AI_recom_services.dart';

class AIPoliticalInsightsWidget extends StatefulWidget {
  const AIPoliticalInsightsWidget({super.key});

  @override
  State<AIPoliticalInsightsWidget> createState() => _AIPoliticalInsightsWidgetState();
}

class _AIPoliticalInsightsWidgetState extends State<AIPoliticalInsightsWidget> {
  final AIRecommendationService _aiService = AIRecommendationService();
  String _aiInsights = '';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAIPoliticalInsights();
  }

  Future<void> _loadAIPoliticalInsights() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final insights = await _generatePoliticalInsights();
      setState(() {
        _aiInsights = insights;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading AI insights: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
        _aiInsights = 'Unable to load political insights at this time. Please check your connection and try again.';
      });
    }
  }

  Future<String> _generatePoliticalInsights() async {
    String prompt = """
    As a political news assistant, provide a brief but insightful overview of current important political developments that readers should be aware of.

    Please structure your response with:
    1. 2-3 key political developments or trends happening right now
    2. Why these matter to citizens
    3. 3-4 specific topics readers should research further

    Focus on:
    - US domestic politics and policy
    - International relations affecting the US
    - Important legislative developments
    - Upcoming political events or elections
    - Issues with significant public impact

    Keep it concise (250-300 words maximum), factual, and balanced.
    Use clear, engaging language that encourages civic engagement.
    Format with clear sections but without markdown.

    End with an encouraging note about the importance of staying informed.
    """;

    final response = await _aiService.replyToUser(prompt);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: tertiaryColor, size: 20),
                  const SizedBox(width: 8),
                  CustomNormalText(
                    text: 'AI Political Insights',
                    color: proffessionalBlack.withAlpha(150),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  const Spacer(),
                  if (!_isLoading)
                    IconButton(
                      icon: Icon(Icons.refresh, size: 18, color: primaryColor),
                      onPressed: _loadAIPoliticalInsights,
                      tooltip: 'Refresh insights',
                    ),
                ],
              ),

              const SizedBox(height: 12),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_hasError)
                Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    CustomNormalText(text: 'Failed to Load Insights', fontSize: 18, color: proffessionalBlack.withAlpha(160),), 
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadAIPoliticalInsights,
                      style: ButtonStyle(
                        elevation: WidgetStatePropertyAll(0), 
                        backgroundColor: WidgetStatePropertyAll(primaryColor), 
                        surfaceTintColor: WidgetStatePropertyAll(secondaryColor.withAlpha(120)), 
                        overlayColor: WidgetStatePropertyAll(tertiaryColor.withAlpha(30)), 
                      ),
                      child: CustomNormalText(text: 'Try Again', fontSize: 16,),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: secondaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _aiInsights,
                        style: TextStyle(
                          fontSize: 14,
                          color: proffessionalBlack.withAlpha(200),
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tertiaryColor.withAlpha(10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: tertiaryColor.withAlpha(50)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.search, size: 16, color: tertiaryColor),
                              const SizedBox(width: 6),
                              CustomNormalText(
                                text: 'Suggested Research Topics',
                                color: tertiaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildResearchChip('Global Climate Policies'), 
                              _buildResearchChip('US Economic Legislation'),
                              _buildResearchChip('International Conflicts'),
                              _buildResearchChip('Domestic Social Issues'),
                              _buildResearchChip('Election Developments'),
                              _buildResearchChip('Technology Regulations'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomNormalText(
                              text: 'Stay informed and engaged with current political developments',
                              color: proffessionalBlack.withAlpha(180),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResearchChip(String topic) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Searching for: $topic'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tertiaryColor.withAlpha(100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          topic,
          style: TextStyle(
            fontSize: 12,
            color: tertiaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}