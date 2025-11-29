// ai_chat_panel.dart
import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/responsive/media_query.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:assets/entities/widgets/text_field/text_field.dart';
import 'package:assets/services/AI_recom_services.dart';
import 'package:assets/services/news_api_services.dart';
import 'package:flutter/material.dart';

class AIChatPanel extends StatefulWidget {
  final NewsArticle? currentArticle;
  final bool isMobile;
  final VoidCallback? onClose;
  final bool isStandaloneMode; 

  const AIChatPanel({
    super.key,
    this.currentArticle,
    required this.isMobile,
    this.onClose,
    this.isStandaloneMode = false,
  });

  @override
  State<AIChatPanel> createState() => _AIChatPanelState();
}

class _AIChatPanelState extends State<AIChatPanel> {
  final AIRecommendationService _aiService = AIRecommendationService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentArticle != null) {
      _addInitialMessage();
    }
  }

  void _addInitialMessage() {
    _messages.add({
      "sender": "ai",
      "text": "I see you're reading about: \"${widget.currentArticle!.title}\". Ask me anything about this news or other political topics!"
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      String aiResponse;
      
      if (widget.currentArticle != null) {
        aiResponse = await _aiService.chatWithArticleContext(
          userMessage: text,
          articleTitle: widget.currentArticle!.title,
          articleDescription: widget.currentArticle!.description,
          articleUrl: widget.currentArticle!.url,
        );
      } else {
        aiResponse = await _aiService.generalPoliticalChat(text);
      }

      if (mounted) {
        setState(() {
          _messages.add({"sender": "ai", "text": aiResponse});
          _isLoading = false;
        });
      }
      
      _scrollToBottom();
    } catch (e) {
      print('Error in _sendMessage: $e');
      if (mounted) {
        setState(() {
          _messages.add({
            "sender": "ai", 
            "text": "I apologize, but I encountered an error processing your request. Please try again in a moment."
          });
          _isLoading = false;
        });
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      if (widget.currentArticle != null) {
        _addInitialMessage();
      }
    });
  }

  void _closePanel() {
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  bool get _hasArticleContext {
    return widget.currentArticle != null && 
           widget.currentArticle!.title.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    /*final screenWidth = deviceData(context).size.width;
    final screenHeight = deviceData(context).size.height;*/
    
    final double panelWidth = widget.isStandaloneMode 
        ? MediaQuery.of(context).size.width 
        : (widget.isMobile ? MediaQuery.of(context).size.width * 0.85 : 350); 
    
    final double panelHeight = widget.isStandaloneMode
        ? MediaQuery.of(context).size.height
        : (widget.isMobile ? MediaQuery.of(context).size.height * 0.55 : 420);


    if (widget.isMobile && _isMinimized && !widget.isStandaloneMode) { 
      return _buildMinimizedButton();
    }


    return Container(
      width: panelWidth,
      height: panelHeight, 
      constraints: BoxConstraints(
        maxWidth: panelWidth,
        maxHeight: panelHeight,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.isStandaloneMode ? BorderRadius.zero : BorderRadius.circular(12),
        boxShadow: widget.isStandaloneMode ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: widget.isStandaloneMode ? null : Border.all(
          color: tertiaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: widget.isStandaloneMode ? 60 : (widget.isMobile ? 42 : 48), 
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: tertiaryColor.withOpacity(widget.isStandaloneMode ? 0.15 : 0.1), 
              borderRadius: widget.isStandaloneMode 
                  ? BorderRadius.zero 
                  : const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
            ),
            child: Row(
              children: [
                Icon(Icons.smart_toy, color: tertiaryColor, 
                    size: widget.isStandaloneMode ? 24 : 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomNormalText(
                        text: widget.isStandaloneMode ? 'CivicConnect AI Assistant' : 'AI News Assistant', 
                        fontSize: widget.isStandaloneMode ? 18 : (widget.isMobile ? 14 : 16), 
                        fontWeight: FontWeight.w600,
                      ),
                      if (_hasArticleContext && (widget.isMobile || widget.isStandaloneMode)) 
                        CustomNormalText(
                          text: 'Discussing: ${_truncateText(widget.currentArticle!.title, widget.isStandaloneMode ? 60 : 40)}', 
                          fontSize: widget.isStandaloneMode ? 14 : 10, 
                        ),
                    ],
                  ),
                ),
                if (widget.isMobile && !widget.isStandaloneMode) ...[ 
                  IconButton(
                    icon: Icon(Icons.minimize, size: 16),
                    onPressed: _toggleMinimize,
                    tooltip: 'Minimize',
                    padding: const EdgeInsets.all(4),
                  ),
                ],
                IconButton(
                  icon: Icon(Icons.clear_all, size: 16),
                  onPressed: _clearChat,
                  tooltip: 'Clear chat',
                  padding: const EdgeInsets.all(4),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 16),
                  onPressed: _closePanel,
                  tooltip: 'Close',
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ),

          if (_hasArticleContext && !widget.isMobile)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                border: Border(bottom: BorderSide(color: Colors.blue.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  Icon(Icons.article, size: 14, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: CustomNormalText(
                      text: 'Discussing: ${_truncateText(widget.currentArticle!.title, 40)}',
                      fontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.smart_toy,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            CustomNormalText(
                              text: _hasArticleContext 
                                  ? 'Ask me about "${_truncateText(widget.currentArticle!.title, 30)}"'
                                  : 'Ask me about political news!',
                              color: Colors.grey,
                              fontSize: widget.isMobile ? 14 : 16,
                              textAlign: TextAlign.center,
                            ),
                            if (_hasArticleContext) ...[
                              const SizedBox(height: 4),
                              CustomNormalText(
                                text: 'or any other political topics',
                                color: Colors.grey,
                                fontSize: 12,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isLoading && index == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        
                        final message = _messages[index];
                        final isUser = message["sender"] == "user";
                        
                        return _buildMessageBubble(
                          message["text"],
                          isUser,
                        );
                      },
                    ),
            ),
          ),

          Container(
            height: widget.isMobile ? (panelWidth > 350 ? 98: 70) : 100,
            padding: const EdgeInsets.all(10), 
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _messageController,
                    hintText: _hasArticleContext 
                        ? "Ask about this article..." 
                        : "Ask about political news...",
                    fillColor: secondaryColor.withAlpha(36),
                    desktopText: '',
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: widget.isMobile ? 36 : 40,
                  height: widget.isMobile ? 36 : 40,
                  decoration: BoxDecoration(
                    color: tertiaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send, 
                      color: Colors.white,
                      size: widget.isMobile ? 16 : 18,
                    ),
                    onPressed: _isLoading ? null : _sendMessage,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildMinimizedButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: tertiaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: proffessionalBlack.withAlpha(36),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: IconButton(
              icon: Icon(Icons.smart_toy, color: Colors.white, size: 24),
              onPressed: _toggleMinimize,
              tooltip: 'Open AI Assistant',
            ),
          ),
          if (_messages.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    final fontSize = widget.isMobile ? 13.0 : 14.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: widget.isMobile ? 24 : 28,
              height: widget.isMobile ? 24 : 28,
              decoration: BoxDecoration(
                color: tertiaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy, 
                color: Colors.white, 
                size: widget.isMobile ? 12 : 14,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: widget.isMobile ? MediaQuery.of(context).size.width * 0.6 : 280,
              ),
              padding: EdgeInsets.all(widget.isMobile ? 10 : 12),
              decoration: BoxDecoration(
                color: isUser ? tertiaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : proffessionalBlack,
                  fontSize: fontSize,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 6),
            Container(
              width: widget.isMobile ? 24 : 28,
              height: widget.isMobile ? 24 : 28,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person, 
                color: Colors.white, 
                size: widget.isMobile ? 12 : 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: widget.isMobile ? 24 : 28,
            height: widget.isMobile ? 24 : 28,
            decoration: BoxDecoration(
              color: tertiaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy, 
              color: Colors.white, 
              size: widget.isMobile ? 12 : 14,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: EdgeInsets.all(widget.isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedDot(0),
                _buildAnimatedDot(1),
                _buildAnimatedDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}