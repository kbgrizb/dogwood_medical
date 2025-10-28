

import 'package:cloud_firestore/cloud_firestore.dart';

class Animal {
  Animal(
    {
    this.id,
    required this.name,

    required this.vaccineStatus,
    this.vaccineType,
    this.vaccineTime,

    required this.dewormStatus,
    this.dewormType,
    this.dewormTime,

    required this.fleaStatus,
    this.fleaType,
    this.fleaTime,

    required this.fecalStatus,
    this.fecalLocation,
    this.fecalTime,

    this.microchipNum,
    });

  String? id;
  final String name;

  bool vaccineStatus;
  String? vaccineType;
  DateTime? vaccineTime;

  bool dewormStatus;
  String? dewormType;
  DateTime? dewormTime;

  bool fleaStatus;
  String? fleaType;
  DateTime? fleaTime;

  bool fecalStatus;
  String? fecalLocation;
  DateTime? fecalTime;

  String? microchipNum;


   static DateTime? _parseDate(dynamic value) { // firebase gets confused if you dont do this
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() { // mapping for firebase
    return {
      'name': name,
      'vaccineStatus': vaccineStatus,
      'vaccineType': vaccineType,
      'vaccineTime': vaccineTime != null ? Timestamp.fromDate(vaccineTime!) : null,
      'dewormStatus': dewormStatus,
      'dewormType': dewormType,
      'dewormTime': dewormTime != null ? Timestamp.fromDate(dewormTime!) : null,
      'fleaStatus': fleaStatus,
      'fleaType': fleaType,
      'fleaTime': fleaTime != null ? Timestamp.fromDate(fleaTime!) : null,
      'fecalStatus': fecalStatus,
      'fecalLocation': fecalLocation,
      'fecalTime': fecalTime != null ? Timestamp.fromDate(fecalTime!) : null,
      'microchipNum': microchipNum,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map, {String? id}) {
    return Animal(
      id: id,
      name: map['name'] ?? '',
      vaccineStatus: map['vaccineStatus'] ?? false,
      vaccineType: map['vaccineType'],
      vaccineTime: _parseDate(map['vaccineTime']),
      dewormStatus: map['dewormStatus'] ?? false,
      dewormType: map['dewormType'],
      dewormTime: _parseDate(map['dewormTime']),
      fleaStatus: map['fleaStatus'] ?? false,
      fleaType: map['fleaType'],
      fleaTime: _parseDate(map['fleaTime']),
      fecalStatus: map['fecalStatus'] ?? false,
      fecalLocation: map['fecalLocation'],
      fecalTime: _parseDate(map['fecalTime']),
      microchipNum: map['microchipNum'],
    );
  }

}