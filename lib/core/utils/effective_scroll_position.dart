import 'package:flutter/material.dart';

ScrollPosition? findEffectiveVerticalScrollPosition(BuildContext context) {
  final positions = <ScrollPosition>[];

  context.visitAncestorElements((element) {
    if (element is StatefulElement && element.state is ScrollableState) {
      final position = (element.state as ScrollableState).position;

      if (axisDirectionToAxis(position.axisDirection) == Axis.vertical) {
        positions.add(position);
      }
    }

    return true;
  });

  if (positions.isEmpty) {
    return null;
  }

  return positions.last;
}
