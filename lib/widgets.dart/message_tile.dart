import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  const MessageTile(
      {super.key,
      required this.message,
      required this.sender,
      required this.sentByme});
  final String message;
  final String sender;
  final bool sentByme;

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByme ? 0 : 24,
          right: widget.sentByme ? 24 : 0),
      alignment: widget.sentByme ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByme
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
        decoration: BoxDecoration(
            borderRadius: widget.sentByme
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20))
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
            color: widget.sentByme
                ? Theme.of(context).primaryColor.withOpacity(0.9)
                : Colors.grey[600]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                letterSpacing: -0.7,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
