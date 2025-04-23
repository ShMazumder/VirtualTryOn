// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:json_annotation/json_annotation.dart';

// part 'glasses_model.g.dart';

// @JsonSerializable()
class GlassesModel {
  GlassesModel({
    required this.assetPath,
    required this.name,
    required this.designer,
    required this.id,
    this.scaleFactor = 1.0, 
  });

  
  final String assetPath;
  final String name;
  final String designer;
  final int id;
  final double scaleFactor;

  factory GlassesModel.fromJson(Map<String, dynamic> json) =>
      GlassesModel(id: json['id'], assetPath: json['assetPath'], name: json['name'], designer: json['designer'], scaleFactor: json['scaleFactor']);

  Map<String, dynamic> toJson() => {'id': id, 'assetPath': assetPath, 'name': name, 'designer': designer, 'scaleFactor': scaleFactor};
}

final List<GlassesModel> glassesList = [
  GlassesModel(
      id: 0,
      assetPath: 'assets/glasses/glasses_0.png',
      name: 'Classic Round',
      designer: 'Ray-Ban',
      scaleFactor: 1.1),
  GlassesModel(
      id: 1,
      assetPath: 'assets/glasses/glasses_1.png',
      name: 'Aviator',
      designer: 'Oakley',
      scaleFactor: 1.0),
  GlassesModel(
      id: 2,
      assetPath: 'assets/glasses/glasses_2.png',
      name: 'Wayfarer',
      designer: 'Prada',
      scaleFactor: 0.9),
  GlassesModel(
      id: 3,
      assetPath: 'assets/glasses/glasses_3.png',
      name: 'Cat Eye',
      designer: 'Dior',
      scaleFactor: 1.05),
  GlassesModel(
      id: 4,
      assetPath: 'assets/glasses/glasses_4.png',
      name: 'Square Frame',
      designer: 'Gucci',
      scaleFactor: 0.95),
];
