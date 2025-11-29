import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/responsive/media_query.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:assets/entities/widgets/text_field/text_field.dart';
import 'package:assets/services/AI_recom_services.dart';
import 'package:flutter/material.dart';

class AISuggestionsPage extends StatefulWidget {
  const AISuggestionsPage({super.key});

  @override
  State<AISuggestionsPage> createState() => _AISuggestionsPageState();
}

class _AISuggestionsPageState extends State<AISuggestionsPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIRecommendationService aiRecommendationService = AIRecommendationService(); 
  
  List<Map<String, dynamic>> messages = [
    {
      "sender": "ai",
      "text": "Hello! I'm your political assistant. I can help you understand current political issues, analyze policies, or discuss recent political developments. What would you like to know?"
    }
  ];

  bool _isAITyping = false;

  String _formatAIResponse(String response) {
    String formatted = response;
    
    Map<String, String> encodingFixes = {
      'â€¢': '•',      // Bullet point
      'â€"': '—',      // Em dash
      'â€“': '–',      // En dash
      'â€™': "'",     // Apostrophe
      'â€œ': '"',      // Left double quote
      'â€': '"',       // Right double quote
      'â€˜': "'",      // Single quote
      'Ã©': 'é',       // Accented e
      'Ã¨': 'è',       // Accented e
      'Ã¢': 'â',       // Accented a
      'Ã®': 'î',       // Accented i
      'Ã´': 'ô',       // Accented o
      'Ã¹': 'ù',       // Accented u
      'Ã§': 'ç',       // Cedilla
      'Â': '',         // Remove unwanted Â
      '###': '',       // Remove markdown headers
      '##': '',        // Remove markdown headers
      '#': '',         // Remove markdown headers
    };
    
    encodingFixes.forEach((key, value) {
      formatted = formatted.replaceAll(key, value);
    });
    
    formatted = formatted
      .replaceAll('*  ', '  \n• ')
      .replaceAll('*', '•')
      .replaceAll('  ', '    ')
      .replaceAll('  ', '  ')
      .replaceAll('\t', '    ')
      .replaceAll('---', '—')
      .replaceAll('--', '–')
      .replaceAll(RegExp(r'\*{3,}'), '') 
      .replaceAll(RegExp(r'#{2,}'), '')
      .replaceAll(RegExp(r'_{2,}'), '');

    formatted = formatted
      .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '')
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
      .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
      .replaceAll(RegExp(r'_(.*?)_'), r'$1')
      .replaceAll('```', '')
      .replaceAll('`', '');
    
    formatted = formatted
      .replaceAll(RegExp(r'^\s*[\*\-]\s+', multiLine: true), '   ')
      .replaceAll(RegExp(r'^\s*•\s+', multiLine: true), '    '); 
    
    List<String> lines = formatted.split('\n');
    List<String> cleanedLines = [];
    
    for (String line in lines) {
      String cleanedLine = line.trim();
      
      if (cleanedLine.isNotEmpty) {
        if (cleanedLine.endsWith(':') || 
            cleanedLine.contains('---') ||
            cleanedLine.contains('###') ||
            cleanedLine.length > 50) {
          cleanedLines.add('');
        }
        cleanedLines.add(cleanedLine);
      }
    }
    
    List<String> finalLines = [];
    for (int i = 0; i < cleanedLines.length; i++) {
      if (i == 0 || cleanedLines[i].isNotEmpty || cleanedLines[i-1].isNotEmpty) {
        finalLines.add(cleanedLines[i]);
      }
    }
    
    return finalLines.join('\n');
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      _isAITyping = true;
    });

    controller.clear();

    // Scroll to bottom after adding user message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    final aiResponse = await sendMessageToAI(text);

    setState(() {
      _isAITyping = false;
      messages.add({
        "sender": "ai", 
        "text": _formatAIResponse(aiResponse) 
      });
    });

    // Scroll to bottom after AI response
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<String> sendMessageToAI(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return aiRecommendationService.replyToUser(prompt); 
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    final isMobile = getScreenSize(context) == 'mobile';
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: isMobile 
            ? MediaQuery.of(context).size.width * 0.75
            : MediaQuery.of(context).size.width * 0.6,
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: isUser ? tertiaryColor : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isUser
            ? null
            : Border.all(
                color: Colors.grey.withAlpha(55),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SelectableText.rich(
        TextSpan(
          children: _parseTextWithFormatting(text),
        ),
        style: TextStyle(
          color: isUser ? Colors.white : proffessionalBlack,
          fontSize: isMobile ? 14 : 16,
          height: 1.4,
          fontFamily: 'Monospace', 
        ),
      ),
    );
  }

  List<TextSpan> _parseTextWithFormatting(String text) {
    List<TextSpan> spans = [];
    List<String> lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      
      bool isIndented = line.startsWith(' ') || 
                       line.startsWith('\u2003') || 
                       line.startsWith('\u2002');
      
      if (isIndented) {
        spans.add(TextSpan(
          text: line,
          style: TextStyle(
            color: proffessionalBlack,
            backgroundColor: i % 2 == 0 ? Colors.grey.withOpacity(0.05) : null,
          ),
        ));
      } else {
        spans.add(TextSpan(text: line));
      }
      
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    
    return spans;
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 6, 
        horizontal: getScreenSize(context) == 'mobile' ? 12 : 16
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: getScreenSize(context) == 'mobile' ? 28 : 32,
            height: getScreenSize(context) == 'mobile' ? 28 : 32,
            decoration: BoxDecoration(
              color: secondaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy, 
              color: Colors.white, 
              size: getScreenSize(context) == 'mobile' ? 14 : 16
            ),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: getScreenSize(context) == 'mobile' 
                  ? MediaQuery.of(context).size.width * 0.75
                  : MediaQuery.of(context).size.width * 0.6,
            ),
            padding: EdgeInsets.all(getScreenSize(context) == 'mobile' ? 12 : 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.grey.withAlpha(55),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDots() {
    return Container(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedDot(0),
          _buildAnimatedDot(1),
          _buildAnimatedDot(2),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: secondaryColor.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            final delay = index * 200;
            final animationValue = (value * 1000 + delay) % 1000 / 1000;
            final opacity = 0.3 + (animationValue * 0.7);
            return Opacity(
              opacity: opacity,
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: secondaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenSize(context) == 'mobile';
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[50],
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: secondaryColor.withAlpha(36),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomNormalText(
              text: 'AI Political Assistant',
              fontSize: isMobile ? 16 : 20,
              color: proffessionalBlack,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
          ),
  
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: ListView.builder(
                controller: _scrollController,
                reverse: true, 
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: messages.length + (_isAITyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isAITyping && index == 0) {
                    return _buildTypingIndicator();
                  }
                  
                  final messageIndex = _isAITyping ? index - 1 : index;
                  final msg = messages[messages.length - 1 - messageIndex];
                  final isUser = msg["sender"] == "user";
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 6, 
                      horizontal: isMobile ? 12 : 16
                    ),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          Container(
                            width: isMobile ? 28 : 32,
                            height: isMobile ? 28 : 32,
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.smart_toy, 
                              color: Colors.white, 
                              size: isMobile ? 14 : 16
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: _buildMessageBubble(msg["text"], isUser),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: isMobile ? 28 : 32,
                            height: isMobile ? 28 : 32,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person, 
                              color: Colors.white, 
                              size: isMobile ? 14 : 16
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: secondaryColor.withAlpha(120),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller,
                    hintText: "Ask something political...",
                    desktopText: '',
                    fillColor: secondaryColor.withAlpha(36),
                    onSubmitted: (value) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: tertiaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send, 
                      color: primaryColor,
                      size: isMobile ? 20 : 24,
                    ),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose(); 
    controller.dispose();
    super.dispose();
  }
}