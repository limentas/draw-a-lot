import 'dart:ui' as dart_ui;

import 'path_part.dart';

enum StepType { Path, Cache }

class HistoryStep {
  HistoryStep.fromPath(this.path) : stepType = StepType.Path;
  HistoryStep.fromCache(this.cache) : stepType = StepType.Cache;

  final stepType;

  PathPart path;
  dart_ui.Image cache;
}
