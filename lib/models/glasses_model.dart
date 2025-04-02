class GlassesModel {
  final String assetPath;
  final String name;
  final String designer;
  final double scaleFactor;

  GlassesModel({
    required this.assetPath,
    required this.name,
    required this.designer,
    this.scaleFactor = 1.0,
  });
}

List<GlassesModel> glassesList = [
  GlassesModel(
    assetPath: 'assets/glasses/glasses_0.png',
    name: 'Classic Round',
    designer: 'Ray-Ban',
    scaleFactor: 1.1,
  ),
  GlassesModel(
    assetPath: 'assets/glasses/glasses_1.png',
    name: 'Aviator',
    designer: 'Oakley',
    scaleFactor: 1.0,
  ),
  GlassesModel(
    assetPath: 'assets/glasses/glasses_2.png',
    name: 'Wayfarer',
    designer: 'Prada',
    scaleFactor: 0.9,
  ),
  GlassesModel(
    assetPath: 'assets/glasses/glasses_3.png',
    name: 'Cat Eye',
    designer: 'Dior',
    scaleFactor: 1.05,
  ),
  GlassesModel(
    assetPath: 'assets/glasses/glasses_4.png',
    name: 'Square Frame',
    designer: 'Gucci',
    scaleFactor: 0.95,
  ),
];