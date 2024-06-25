import 'dart:math';

import 'package:flutter/material.dart';

class Cube extends StatelessWidget {
  final double angleX;
  final double angleY;
  final double angleZ;
  final double size;

  const Cube({
    super.key,
    required this.angleX,
    required this.angleY,
    required this.angleZ,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..rotateX((angleX % 360) * pi / 180)
          ..rotateY(-(angleY % 360) * pi / 180)
          ..rotateZ((angleZ % 360) * pi / 180),
        alignment: Alignment.center,
        child: Stack(
          children: [
            CubeSide(
              face: CubeFace.back,
              cubeSize: size,
            ),
            CubeSide(
              face: CubeFace.left,
              cubeSize: size,
            ),
            CubeSide(
              face: CubeFace.right,
              cubeSize: size,
            ),
            CubeSide(
              face: CubeFace.bottom,
              cubeSize: size,
            ),
            CubeSide(
              face: CubeFace.top,
              cubeSize: size,
            ),
            CubeSide(
              face: CubeFace.front,
              cubeSize: size,
              isFront: true,
            )
          ],
        ),
      ),
    );
  }
}

enum CubeFace {
  top,
  bottom,
  front,
  back,
  right,
  left;

  String get faceName {
    switch (this) {
      case CubeFace.top:
        return 'top';
      case CubeFace.bottom:
        return 'bottom';
      case CubeFace.front:
        return 'front';
      case CubeFace.back:
        return 'back';
      case CubeFace.right:
        return 'right';
      case CubeFace.left:
        return 'left';
    }
  }

  List<double> getTranslateArr(double size) {
    switch (this) {
      case CubeFace.top:
        return [0, size / 2, 0];
      case CubeFace.bottom:
        return [0, -size / 2, 0];
      case CubeFace.front:
        return [0, 0, size / 2];
      case CubeFace.back:
        return [0, 0, -size / 2];
      case CubeFace.right:
        return [size / 2, 0, 0];
      case CubeFace.left:
        return [-size / 2, 0, 0];
    }
  }

  List<double> get rotation {
    switch (this) {
      case CubeFace.top:
      case CubeFace.bottom:
        return [pi, 0];
      case CubeFace.front:
      case CubeFace.back:
        return [0, 0];
      case CubeFace.right:
      case CubeFace.left:
        return [0, pi];
    }
  }
}

class CubeSide extends StatelessWidget {
  final CubeFace face;
  final double cubeSize;
  final bool isFront;
  const CubeSide({
    super.key,
    required this.face,
    required this.cubeSize,
    this.isFront = false,
  });

  @override
  Widget build(BuildContext context) {
    final transArr = face.getTranslateArr(cubeSize);
    final rotArr = face.rotation;
    return Transform(
      key: ValueKey(face.faceName),
      transform: Matrix4.identity()
        ..translate(transArr[0], transArr[1], transArr[2])
        ..rotateX(rotArr[0] / 2)
        ..rotateY(rotArr[1] / 2),
      alignment: Alignment.center,
      child: Container(
        color:
            isFront ? const Color.fromARGB(255, 26, 255, 0) : Colors.grey[600],
        child: Container(
          width: cubeSize,
          height: cubeSize,
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        ),
      ),
    );
  }
}
