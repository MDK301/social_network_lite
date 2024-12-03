import 'package:flutter/material.dart';

import '../../domain/entities/messenger.dart';

class MessengerBubble extends StatelessWidget {
  final Messenger messenger;
  final bool isMe;

  const MessengerBubble({
    Key? key,
    required this.isMe,required this.messenger,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.inversePrimary
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            message,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(timestamp.toString()),
        ]),
      ),
    );
  }
}
