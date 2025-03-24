import 'dart:ui' as dart_ui;

import 'pen_path.dart';

enum StepType { Path, Cache }

class HistoryStep {
  HistoryStep.fromPath(this.path) : stepType = StepType.Path;
  HistoryStep.fromCache(this.cache) : stepType = StepType.Cache;

  final stepType;

  PenPath? path = null;
  dart_ui.Image? cache = null;
}
