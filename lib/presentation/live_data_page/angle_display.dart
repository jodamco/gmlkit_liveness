import 'package:flutter/material.dart';
import 'package:gmlkit_liveness/presentation/widgets/cube/cube.dart';
import 'package:google_fonts/google_fonts.dart';

class AnglesDisplay extends StatelessWidget {
  final List<double> angles;

  const AnglesDisplay({super.key, required this.angles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Cube(
          angleX: angles[0],
          angleY: angles[1],
          angleZ: angles[2],
          size: 55,
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          "x: ${angles[0].toStringAsFixed(2)}",
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 26, 255, 0),
          ),
        ),
        Text(
          "y: ${angles[1].toStringAsFixed(2)}",
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 26, 255, 0),
          ),
        ),
        Text(
          "z: ${angles[2].toStringAsFixed(2)}",
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 26, 255, 0),
          ),
        ),
      ],
    );
  }
}
