import 'package:flutter/material.dart';

import 'note_card.dart';
import 'swipe_action_background.dart';
import 'swipe_note_tile.dart';

class SwipeNoteTileState extends State<SwipeNoteTile>
    with SingleTickerProviderStateMixin {
  static const _actionWidth = 88.0;
  static const _revealThreshold = _actionWidth / 2;
  static const _revealVelocity = 700.0;

  late final AnimationController _controller;
  Animation<double>? _animation;
  double _offset = 0;
  bool _isActing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    )..addListener(_onAnimationTick);
    widget.openNoteId.addListener(_onOpenNoteChanged);
  }

  @override
  void dispose() {
    widget.openNoteId.removeListener(_onOpenNoteChanged);
    _controller
      ..removeListener(_onAnimationTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          width: constraints.maxWidth,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned.fill(
                child: SwipeActionBackground(
                  offset: _offset,
                  actionWidth: _actionWidth,
                  onAction: _performRevealedAction,
                ),
              ),
              Transform.translate(
                key: ValueKey('swipe-translation-${widget.note.id}'),
                offset: Offset(_offset, 0),
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onForegroundTap,
                    onHorizontalDragStart: _onHorizontalDragStart,
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    onHorizontalDragCancel: _onHorizontalDragCancel,
                    child: NoteCard(note: widget.note, onTap: () {}),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_isActing) return;
    _controller.stop();
    _animation = null;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isActing) return;
    setState(() {
      _offset = (_offset + details.delta.dx).clamp(-_actionWidth, _actionWidth);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isActing) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final shouldReveal =
        _offset.abs() >= _revealThreshold ||
        (velocity.abs() >= _revealVelocity && velocity.sign == _offset.sign);
    _settle(shouldReveal ? _offset.sign * _actionWidth : 0);
  }

  void _onHorizontalDragCancel() {
    if (!_isActing) _settle(0);
  }

  void _onForegroundTap() {
    if (_offset == 0) {
      widget.onTap();
    } else {
      _close();
    }
  }

  void _onOpenNoteChanged() {
    if (widget.openNoteId.value != widget.note.id && _offset != 0) {
      _animateTo(0);
    }
  }

  void _settle(double target) {
    if (target == 0) {
      if (widget.openNoteId.value == widget.note.id) {
        widget.openNoteId.value = null;
      }
    } else {
      widget.openNoteId.value = widget.note.id;
    }
    _animateTo(target);
  }

  Future<void> _performRevealedAction() async {
    if (_isActing || _offset == 0) return;
    _isActing = true;
    try {
      if (_offset < 0) {
        await widget.onDelete();
      } else {
        await widget.onToggleFavorite();
      }
    } finally {
      if (mounted) {
        _isActing = false;
        _close();
      }
    }
  }

  void _close() => _settle(0);

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
