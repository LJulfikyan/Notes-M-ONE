import 'package:flutter/material.dart';

import '../../domain/note.dart';
import 'note_card.dart';
import 'swipe_action_background.dart';

class SwipeNoteTile extends StatefulWidget {
  const SwipeNoteTile({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onToggleFavorite,
    required this.onTap,
  });

  final Note note;
  final Future<void> Function() onDelete;
  final Future<void> Function() onToggleFavorite;
  final VoidCallback onTap;

  @override
  State<SwipeNoteTile> createState() => _SwipeNoteTileState();
}

class _SwipeNoteTileState extends State<SwipeNoteTile>
    with SingleTickerProviderStateMixin {
  static const _commitVelocity = 700.0;
  static const _minimumCommitDistance = 96.0;

  late final AnimationController _controller;
  Animation<double>? _animation;
  double _offset = 0;
  double _width = 1;
  bool _isCommitting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    )..addListener(_onAnimationTick);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onAnimationTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            children: [
              Positioned.fill(child: SwipeActionBackground(offset: _offset)),
              Transform.translate(
                key: ValueKey('swipe-translation-${widget.note.id}'),
                offset: Offset(_offset, 0),
                child: NoteCard(note: widget.note, onTap: () {}),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.onTap,
                  onHorizontalDragStart: _onHorizontalDragStart,
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  onHorizontalDragCancel: _onHorizontalDragCancel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_isCommitting) {
      return;
    }
    _controller.stop();
    _animation = null;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isCommitting) {
      return;
    }
    setState(() {
      _offset = (_offset + details.delta.dx).clamp(-_width, _width);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isCommitting) {
      return;
    }
    final velocity = details.velocity.pixelsPerSecond.dx;
    final isFavorite = _offset > 0 && _shouldCommit(velocity);
    final isDelete = _offset < 0 && _shouldCommit(velocity);
    if (isFavorite) {
      _commit(widget.onToggleFavorite, _width);
    } else if (isDelete) {
      _commit(widget.onDelete, -_width);
    } else {
      _animateTo(0);
    }
  }

  void _onHorizontalDragCancel() {
    if (!_isCommitting) {
      _animateTo(0);
    }
  }

  bool _shouldCommit(double velocity) {
    final distanceThreshold = (_width * 0.35).clamp(
      _minimumCommitDistance,
      _width,
    );
    return _offset.abs() >= distanceThreshold ||
        velocity.abs() >= _commitVelocity;
  }

  Future<void> _commit(Future<void> Function() action, double target) async {
    _isCommitting = true;
    if (!await _animateTo(target) || !mounted) {
      if (mounted) {
        _isCommitting = false;
        _animateTo(0);
      }
      return;
    }
    try {
      await action();
    } finally {
      if (mounted) {
        _isCommitting = false;
        _animateTo(0);
      }
    }
  }

  Future<bool> _animateTo(double target) async {
    _animation = Tween<double>(
      begin: _offset,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.value = 0;
    try {
      await _controller.forward().orCancel;
      return mounted;
    } on TickerCanceled {
      return false;
    }
  }

  void _onAnimationTick() {
    final animation = _animation;
    if (animation != null && mounted) {
      setState(() => _offset = animation.value);
    }
  }
}
