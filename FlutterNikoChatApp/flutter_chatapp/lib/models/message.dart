import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Message {
  Message({
    required this.msg,
    required this.RecieverId,
    required this.read,
    required this.type,
    required this.SenderId,
    required this.sent,
  });
  late final String msg;
  late final String RecieverId;
  late final String read;
  late final String SenderId;
  late final String sent;
  late final Type type;


  Message.fromJson(Map<String, dynamic> json){
    msg = json['msg'].toString();
    RecieverId = json['RecieverId'].toString();
    read = json['read'].toString();
    //Compares the text type and checks wheter image path or text
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    SenderId = json['SenderId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['msg'] = msg;
    _data['RecieverId'] = RecieverId;
    _data['read'] = read;
    _data['type'] = type.name;
    _data['SenderId'] = SenderId;
    _data['sent'] = sent;
    return _data;
  }


}

enum Type{text, image}