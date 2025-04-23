import 'package:flutter/material.dart';
import '../../models/glasses_model.dart';

class GlassesSelector extends StatelessWidget {
  final List<GlassesModel> glassesList;
  final int selectedGlasses;
  final Function(int) onGlassesSelected;

  const GlassesSelector({super.key,
    required this.glassesList,
    required this.selectedGlasses,
    required this.onGlassesSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: glassesList.length,
          itemBuilder: (context, index) {
            final glasses = glassesList[index];
            return GestureDetector(
              onTap: () => onGlassesSelected(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 100,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedGlasses == index
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        glasses.assetPath,
                        width: 80,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      glasses.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}