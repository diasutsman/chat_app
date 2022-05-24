import 'package:flutter/material.dart';

const kSendButtonTextStyle =
    TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold);

const kMessageTextFieldDecoration = InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    hintText: 'Type your message here...',
    border: InputBorder.none,
    hintStyle: TextStyle(
      color: Colors.grey
    )
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0)
  )
);
