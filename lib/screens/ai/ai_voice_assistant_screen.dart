import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_assistant_provider.dart';

/// AI Voice Assistant Screen
/// Interactive voice-based emergency assistant
class AiVoiceAssistantScreen extends StatefulWidget {
  final String emergencyType;
  final String emergencyTitle;

  const AiVoiceAssistantScreen({
    super.key,
    required this.emergencyType,
    required this.emergencyTitle,
  });

  @override
  State<AiVoiceAssistantScreen> createState() => _AiVoiceAssistantScreenState();
}

class _AiVoiceAssistantScreenState extends State<AiVoiceAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AiAssistantProvider>()
          .startConversation(widget.emergencyType);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.emergencyTitle),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AiAssistantProvider>(
        builder: (context, provider, child) {
          // Scroll to bottom when new message arrives
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              // Messages Area
              Expanded(
                child: provider.messages.isEmpty && provider.isProcessing
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('جاري تهيئة المساعد الذكي...'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final message = provider.messages[index];
                          return _MessageBubble(message: message);
                        },
                      ),
              ),

              // Processing indicator
              if (provider.isProcessing)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[200],
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('المساعد يفكر...'),
                    ],
                  ),
                ),

              // Error message
              if (provider.errorMessage != null)
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => provider.clearError(),
                      ),
                    ],
                  ),
                ),

              // Input Area
              _InputArea(
                controller: _textController,
                provider: provider,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Input area with voice and text
class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final AiAssistantProvider provider;

  const _InputArea({
    required this.controller,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice transcript
            if (provider.currentTranscript.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  provider.currentTranscript,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

            Row(
              children: [
                // Text input
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        provider.sendTextMessage(text);
                        controller.clear();
                      }
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // Voice button
                GestureDetector(
                  onTapDown: (_) => provider.startListening(),
                  onTapUp: (_) => provider.stopListeningAndProcess(),
                  onTapCancel: () => provider.stopListeningAndProcess(),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: provider.isListening ? Colors.red : Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (provider.isListening ? Colors.red : Colors.blue)
                                  .withAlpha(100),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      provider.isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                // Stop speaking button
                if (provider.isSpeaking) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => provider.stopSpeaking(),
                    icon: const Icon(Icons.stop_circle),
                    color: Colors.orange,
                    iconSize: 40,
                    tooltip: 'إيقاف القراءة',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
