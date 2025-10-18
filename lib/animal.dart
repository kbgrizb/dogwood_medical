

class Animal {
  Animal(
    {required this.name,

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
    });


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

}