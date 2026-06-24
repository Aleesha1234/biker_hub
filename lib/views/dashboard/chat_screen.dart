import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../utils/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String groupName;
  final Color groupColor;

  const ChatScreen({
    super.key,
    required this.groupName,
    required this.groupColor,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final User? _user = FirebaseAuth.instance.currentUser;
  late DatabaseReference _chatRef;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages = []; // Start with a fresh, empty list for each group
    final groupKey =
        widget.groupName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
    _chatRef = FirebaseDatabase.instance.ref('chats/$groupKey');
    _listenToMessages();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ─── Listen Firebase Realtime ──────────────────────────
  void _listenToMessages() {
    _chatRef.onChildAdded.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final isMe = data['uid'] == _user?.uid;
        final senderName = data['sender'] ?? 'Unknown';

        // Calculate initials from sender name
        String initials = 'U';
        if (senderName.isNotEmpty) {
          initials = senderName[0].toUpperCase();
        }

        if (mounted) {
          setState(() {
            _messages.add({
              'sender': senderName,
              'initials': initials,
              'message': data['message'] ?? '',
              'time': data['time'] ?? '',
              'isMe': isMe,
            });
          });
          _scrollToBottom();
        }
      }
    });
  }

  // ─── Send Message ──────────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr =
        "${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period.name.toUpperCase()}";

    _msgCtrl.clear();

    try {
      await _chatRef.push().set({
        'uid': _user?.uid,
        'sender': _user?.displayName ?? 'Rider',
        'message': text,
        'time': timeStr,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Chat error: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.greyLt,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── Messages ─────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessageBubble(_messages[i]),
            ),
          ),
          // ── Input Bar ────────────────────────────────
          _buildInputBar(),
        ],
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: widget.groupColor,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.group_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(widget.groupName,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Colors.white,
              )),
        ],
      ),
      actions: const [],
    );
  }

  // ─── Message Bubble ─────────────────────────────────────
  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar (other person)
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: widget.groupColor.withOpacity(0.15),
              child: Text(
                msg['initials'] as String,
                style: TextStyle(
                  color: widget.groupColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? widget.groupColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(msg['sender'] as String,
                        style: TextStyle(
                          color: widget.groupColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        )),
                  if (!isMe) const SizedBox(height: 3),
                  Text(msg['message'] as String,
                      style: TextStyle(
                        color: isMe ? Colors.white : BikerColors.black,
                        fontSize: 14,
                        height: 1.4,
                      )),
                  const SizedBox(height: 4),
                  Text(msg['time'] as String,
                      style: TextStyle(
                        color: isMe ? Colors.white60 : Colors.grey,
                        fontSize: 10,
                      )),
                ],
              ),
            ),
          ),

          // Avatar (me)
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: widget.groupColor.withOpacity(0.15),
              child: Text(
                _user?.displayName?[0].toUpperCase() ?? 'M',
                style: TextStyle(
                  color: widget.groupColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Input Bar ───────────────────────────────────────────
  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                child: TextField(
                  controller: _msgCtrl,
                  maxLines: 5,
                  minLines: 1,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.groupColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.groupColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
