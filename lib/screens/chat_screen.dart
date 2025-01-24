import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool>? onThemeChanged;

  const ChatScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeChanged,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert message to JSON for storage
  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  // Create message from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isModelInitialized = false;
  String _errorMessage = '';
  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _initializeModel();
    _loadChatHistory();
  }

  void _initializeModel() {
    try {
      const apiKey = 'AIzaSyAbNed7yiVwIdENcLq_-3rI67vWwvqv880';
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );
      _chat = _model.startChat();
      setState(() {
        _isModelInitialized = true;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize model: $e';
        _isModelInitialized = false;
      });
    }
  }

  // Save chat history to SharedPreferences
  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final messageJsonList = _messages.map((msg) => msg.toJson()).toList();
    await prefs.setString('chat_history', json.encode(messageJsonList));
  }

  // Load chat history from SharedPreferences
  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('chat_history');

    if (historyJson != null) {
      final List<dynamic> messageJsonList = json.decode(historyJson);
      setState(() {
        _messages.addAll(messageJsonList.map((msgJson) =>
            ChatMessage.fromJson(msgJson as Map<String, dynamic>)));
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    if (!_isModelInitialized) {
      setState(() {
        _errorMessage = 'Model not initialized. Please check your API key.';
      });
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _isLoading = true;
      _errorMessage = '';
      _controller.clear();
    });

    // Save chat history after adding user message
    await _saveChatHistory();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final responseText = response.text;

      setState(() {
        if (responseText != null) {
          _messages.add(ChatMessage(
            text: responseText,
            isUser: false,
          ));
        } else {
          _messages.add(ChatMessage(
            text: 'No response received',
            isUser: false,
          ));
        }
        _isLoading = false;
      });

      // Save chat history after adding AI response
      await _saveChatHistory();

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      setState(() {
        _errorMessage = 'Error generating response: $e';
        _isLoading = false;
      });
    }
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _chat = _model.startChat();
      _errorMessage = '';
    });
    _saveChatHistory(); // Clear saved history
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    // If onThemeChanged is provided, call it
    widget.onThemeChanged?.call(_isDarkMode);
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: message.isUser ? 64.0 : 16.0,
          right: message.isUser ? 16.0 : 64.0,
          top: 8.0,
          bottom: 8.0,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : _isDarkMode
                  ? Colors.grey[800]
                  : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(message.isUser ? 20.0 : 4.0),
            topRight: Radius.circular(message.isUser ? 4.0 : 20.0),
            bottomLeft: const Radius.circular(20.0),
            bottomRight: const Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser
                    ? Colors.white
                    : _isDarkMode
                        ? Colors.white
                        : Colors.black87,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: message.isUser
                    ? Colors.white70
                    : _isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chat with Gemini',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: 'Toggle Theme',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetChat,
              tooltip: 'Reset chat',
            ),
          ],
        ),
        body: Column(
          children: [
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.red[900] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.red,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _buildMessageBubble(_messages[index]),
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Thinking...'),
                  ],
                ),
              ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12.0),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                color: Colors.white,
                onPressed: _sendMessage,
                tooltip: 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}