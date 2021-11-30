library left_press_draggable;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum DraggableButton { left, right, middle }

extension on DraggableButton {
  int get code {
    switch (this) {
      case DraggableButton.left:
        return 1;
      case DraggableButton.right:
        return 2;
      case DraggableButton.middle:
        return 4;
    }
  }
}

/// Makes its child draggable starting from long press.
///
/// See also:
///
///  * [Draggable], similar to the [LongPressDraggable] widget but happens immediately.
///  * [DragTarget], a widget that receives data when a [Draggable] widget is dropped.
class LeftPressDraggable<T extends Object> extends Draggable<T> {
  /// Creates a widget that can be dragged starting from long press.
  ///
  /// The [child] and [feedback] arguments must not be null. If
  /// [maxSimultaneousDrags] is non-null, it must be non-negative.
  const LeftPressDraggable({
    Key? key,
    required Widget child,
    required Widget feedback,
    T? data,
    Axis? axis,
    Widget? childWhenDragging,
    Offset feedbackOffset = Offset.zero,
    DragAnchorStrategy? dragAnchorStrategy,
    int? maxSimultaneousDrags,
    VoidCallback? onDragStarted,
    DragUpdateCallback? onDragUpdate,
    DraggableCanceledCallback? onDraggableCanceled,
    DragEndCallback? onDragEnd,
    VoidCallback? onDragCompleted,
    bool ignoringFeedbackSemantics = true,
    this.buttons = const [
      DraggableButton.left,
      DraggableButton.right,
      DraggableButton.middle,
    ],
  }) : super(
          key: key,
          child: child,
          feedback: feedback,
          data: data,
          axis: axis,
          childWhenDragging: childWhenDragging,
          feedbackOffset: feedbackOffset,
          dragAnchorStrategy: dragAnchorStrategy,
          maxSimultaneousDrags: maxSimultaneousDrags,
          onDragStarted: onDragStarted,
          onDragUpdate: onDragUpdate,
          onDraggableCanceled: onDraggableCanceled,
          onDragEnd: onDragEnd,
          onDragCompleted: onDragCompleted,
          ignoringFeedbackSemantics: ignoringFeedbackSemantics,
        );

  final List<DraggableButton> buttons;

  /// Creates a gesture recognizer that recognizes the start of the drag.
  ///
  /// Subclasses can override this function to customize when they start
  /// recognizing a drag.
  @override
  @protected
  MultiDragGestureRecognizer createRecognizer(GestureMultiDragStartCallback onStart) {
    switch (affinity) {
      case Axis.horizontal:
        return LeftHorizontalMultiDragGestureRecognizer(
          buttonCodes: buttons.map((e) => e.code).toList(),
        )..onStart = onStart;
      case Axis.vertical:
        return LeftVerticalMultiDragGestureRecognizer(
          buttonCodes: buttons.map((e) => e.code).toList(),
        )..onStart = onStart;
      case null:
        return LeftImmediateMultiDragGestureRecognizer(
          buttonCodes: buttons.map((e) => e.code).toList(),
        )..onStart = onStart;
    }
  }
}

/// Recognizes movement in the horizontal direction on a per-pointer basis.
///
/// In contrast to [HorizontalDragGestureRecognizer],
/// [HorizontalMultiDragGestureRecognizer] watches each pointer separately,
/// which means multiple drags can be recognized concurrently if multiple
/// pointers are in contact with the screen.
///
/// See also:
///
///  * [HorizontalDragGestureRecognizer], a gesture recognizer that just
///    looks at horizontal movement.
///  * [ImmediateMultiDragGestureRecognizer], a similar recognizer, but without
///    the limitation that the drag must start horizontally.
///  * [VerticalMultiDragGestureRecognizer], which only recognizes drags that
///    start vertically.
class LeftHorizontalMultiDragGestureRecognizer extends MultiDragGestureRecognizer {
  /// Create a gesture recognizer for tracking multiple pointers at once
  /// but only if they first move horizontally.
  ///
  /// {@macro flutter.gestures.GestureRecognizer.supportedDevices}
  LeftHorizontalMultiDragGestureRecognizer({
    Object? debugOwner,
    @Deprecated(
      'Migrate to supportedDevices. '
      'This feature was deprecated after v2.3.0-1.0.pre.',
    )
        PointerDeviceKind? kind,
    Set<PointerDeviceKind>? supportedDevices,
    this.buttonCodes = const [],
  }) : super(
          debugOwner: debugOwner,
          kind: kind,
          supportedDevices: supportedDevices,
        );
  final List<int> buttonCodes;

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) {
    return _HorizontalPointerState(
        event.position, buttonCodes.contains(event.buttons), event.kind);
  }

  @override
  String get debugDescription => 'horizontal multidrag';
}

/// Recognizes movement in the vertical direction on a per-pointer basis.
///
/// In contrast to [VerticalDragGestureRecognizer],
/// [VerticalMultiDragGestureRecognizer] watches each pointer separately,
/// which means multiple drags can be recognized concurrently if multiple
/// pointers are in contact with the screen.
///
/// See also:
///
///  * [VerticalDragGestureRecognizer], a gesture recognizer that just
///    looks at vertical movement.
///  * [ImmediateMultiDragGestureRecognizer], a similar recognizer, but without
///    the limitation that the drag must start vertically.
///  * [HorizontalMultiDragGestureRecognizer], which only recognizes drags that
///    start horizontally.
class LeftVerticalMultiDragGestureRecognizer extends MultiDragGestureRecognizer {
  /// Create a gesture recognizer for tracking multiple pointers at once
  /// but only if they first move vertically.
  ///
  /// {@macro flutter.gestures.GestureRecognizer.supportedDevices}
  LeftVerticalMultiDragGestureRecognizer({
    Object? debugOwner,
    @Deprecated(
      'Migrate to supportedDevices. '
      'This feature was deprecated after v2.3.0-1.0.pre.',
    )
        PointerDeviceKind? kind,
    Set<PointerDeviceKind>? supportedDevices,
    this.buttonCodes = const [],
  }) : super(
          debugOwner: debugOwner,
          kind: kind,
          supportedDevices: supportedDevices,
        );
  final List<int> buttonCodes;

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) {
    return _VerticalPointerState(
        event.position, buttonCodes.contains(event.buttons), event.kind);
  }

  @override
  String get debugDescription => 'vertical multidrag';
}

class LeftImmediateMultiDragGestureRecognizer extends MultiDragGestureRecognizer {
  /// Create a gesture recognizer for tracking multiple pointers at once.
  ///
  /// {@macro flutter.gestures.GestureRecognizer.supportedDevices}
  LeftImmediateMultiDragGestureRecognizer({
    Object? debugOwner,
    @Deprecated(
      'Migrate to supportedDevices. '
      'This feature was deprecated after v2.3.0-1.0.pre.',
    )
        PointerDeviceKind? kind,
    Set<PointerDeviceKind>? supportedDevices,
    this.buttonCodes = const [],
  }) : super(
          debugOwner: debugOwner,
          kind: kind,
          supportedDevices: supportedDevices,
        );
  final List<int> buttonCodes;

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) {
    return _ImmediatePointerState(
        event.position, buttonCodes.contains(event.buttons), event.kind);
  }

  @override
  String get debugDescription => 'multidrag';
}

class _HorizontalPointerState extends MultiDragPointerState {
  _HorizontalPointerState(Offset initialPosition, this.isLeft, PointerDeviceKind kind)
      : super(initialPosition, kind);
  final bool isLeft;

  @override
  void checkForResolutionAfterMove() {
    assert(pendingDelta != null);
    if (pendingDelta!.dx.abs() > computeHitSlop(kind)) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    if (isLeft) starter(initialPosition);
  }
}

class _VerticalPointerState extends MultiDragPointerState {
  _VerticalPointerState(Offset initialPosition, this.isLeft, PointerDeviceKind kind)
      : super(initialPosition, kind);
  final bool isLeft;

  @override
  void checkForResolutionAfterMove() {
    assert(pendingDelta != null);
    if (pendingDelta!.dy.abs() > computeHitSlop(kind)) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    if (isLeft) starter(initialPosition);
  }
}

class _ImmediatePointerState extends MultiDragPointerState {
  _ImmediatePointerState(Offset initialPosition, this.isLeft, PointerDeviceKind kind)
      : super(initialPosition, kind);
  final bool isLeft;

  @override
  void checkForResolutionAfterMove() {
    assert(pendingDelta != null);
    if (pendingDelta!.distance > computeHitSlop(kind)) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    if (isLeft) starter(initialPosition);
  }
}
