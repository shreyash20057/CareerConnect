import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';
import '../../../models/user_model.dart';
import '../../../models/job_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  UserModel? _userProfile;
  JobModel? _selectedJob;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  ChatProvider() {
    _messages.add(ChatMessage(
      text:
          "Hi! I'm your **AI Career Assistant**. I can help you with:\n\n• Career guidance and planning\n• Interview preparation\n• Skill gap analysis\n• Resume improvement\n• Job-specific prep\n\nWhat would you like to know?",
      isUser: false,
    ));
  }

  void setContext({UserModel? user, JobModel? job}) {
    _userProfile = user;
    _selectedJob = job;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final history = _messages
          .where((m) => !m.isError)
          .skip(1) // skip greeting
          .take(_messages.length - 2) // exclude last user message
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();

      final reply = await _aiService.chat(
        userMessage: text,
        history: history,
        userProfile: _userProfile,
        selectedJob: _selectedJob,
      );

      _messages.add(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      _messages.add(ChatMessage(
        text:
            'I encountered a connection error. Please check your internet and try again.',
        isUser: false,
        isError: true,
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessage(
      text:
          "Hi! I'm your AI Career Assistant. How can I help you today?",
      isUser: false,
    ));
    notifyListeners();
  }
}