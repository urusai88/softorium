import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:intl/intl.dart';

import '../../../../infrastructure/database.dart';
import '../../../constants.dart';
import '../../../functions.dart';
import '../../../widgets/conditionally_absorb_pointer.dart';
import '../../../widgets/my_color_tween.dart';

const _dayColor = Colors.black;
const _dayColorS = Colors.white;
const _dayTextColor = Color(0xFFAFABC6);
const _dayTextColorS = Colors.white;
const _backColor = Colors.white;
const _backColorS = Color(0xFFBEB7EB);

const _taskTitleColor = Colors.black;
const _taskTitleColorCompleted = Color(0xFFCECECE);
const _taskCircleColor = Color(0xFFEDEBF9);
const _taskCircleColorCompleted = Color(0xFFCECECE);

final _dayFormat = DateFormat('dd.MM.yyyy');
final _keyFormat = DateFormat('dd.MM.yyyy');

String _formatKey(DateTime dateTime) => _keyFormat.format(dateTime);

DateTime _normalizeDateTime(DateTime dateTime) =>
    DateTime(dateTime.year, dateTime.month, dateTime.day);

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();

  late DateTime _selected;

  final _todos = <String, List<TodoItem>>{};
  final _loadings = <String>[];

  final _pointerKey = GlobalKey();

  int? _selectedTodoId;

  bool _editMode = false;

  OverlayEntry? _entry;

  MyDatabase get database => MyDatabase.of(context);

  @override
  void initState() {
    super.initState();
    _selected = _normalizeDateTime(DateTime.now());
  }

  Future<void> _loadTodos(DateTime dateTime) async {
    dateTime = _normalizeDateTime(dateTime);
    final key = _formatKey(dateTime);
    if (_todos.containsKey(key) || _loadings.contains(key)) {
      return;
    }
    final todos = await database.todosInDay(dateTime);
    setState(() {
      _loadings.remove(key);
      _todos[key] = todos;
    });
  }

  Future<void> _addTodo(String value) async {
    _entry?.remove();
    _entry = null;
    _focusNode.unfocus();
    _textEditingController.clear();
    setState(() => _editMode = false);
    value = value.trim();
    if (value.isNotEmpty) {
      final todo = await database.addTodo(value);
      setState(() => _todos[_formatKey(_selected)]!.add(todo));
    }
  }

  Future<void> _deleteTodo(TodoItem todo) async {
    final key = _formatKey(_selected);
    await database.deleteTodo(todo);
    setState(() => _todos[key]!.remove(todo));
  }

  Future<void> _setCompleted(TodoItem item) async {
    final updated = item.copyWith(completed: true);
    await database.updateTodo(updated);
    setState(() {
      final i = _todos[_formatKey(_selected)]!.indexOf(item);
      _todos[_formatKey(_selected)]![i] = updated;
    });
  }

  void _onBeginEdit() {
    setState(() => _editMode = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
    _entry = OverlayEntry(
      builder: (_) => TodoListTileOverlay(
        pointerKey: _pointerKey,
        onTapOutside: () => unawaited(_addTodo(_textEditingController.text)),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(30));

    final result = ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: borderRadius,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x26034714),
              offset: Offset(0, 4),
              blurRadius: 8,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DatesCarousel(
              selected: _selected,
              onSelectedChanged: (v) => setState(() => _selected = v),
              loadTodoCallback: _loadTodos,
            ),
            Flexible(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(8),
                    if (!_todos.containsKey(_formatKey(_selected))) ...[
                      const Gap(6),
                      const Center(child: CircularProgressIndicator()),
                    ] else ...[
                      Text(
                        'План на день ${_dayFormat.format(_selected)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          height: 24 / 14,
                          color: Colors.black,
                        ),
                      ),
                      const Gap(20),
                      Flexible(
                        child: CustomScrollView(
                          key: _pointerKey,
                          shrinkWrap: true,
                          slivers: [
                            if (_todos[_formatKey(_selected)] case final todos?)
                              SliverList.builder(
                                itemCount: todos.length,
                                itemBuilder: (context, index) {
                                  final todo = todos[index];
                                  return TodoListTile(
                                    key: Key('todo-${todo.id}'),
                                    contents: todo.description,
                                    completed: todo.completed,
                                    selected: _selectedTodoId == todo.id,
                                    onTap: () => setState(
                                      () => _selectedTodoId = todo.id,
                                    ),
                                    onLongPress: () async =>
                                        _setCompleted(todo),
                                    onDelete: () =>
                                        unawaited(_deleteTodo(todo)),
                                  );
                                },
                              ),
                            SliverToBoxAdapter(
                              child: TodoListTile.create(
                                contents: 'Новая задача',
                                onSubmit: _addTodo,
                                controller: _textEditingController,
                                focusNode: _focusNode,
                                onTap: _onBeginEdit,
                                editMode: _editMode,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Gap(14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: pagePadding,
      child: Align(
        alignment: Alignment.topCenter,
        child: result,
      ),
    );
  }
}

class TodoListTileOverlay extends StatelessWidget {
  const TodoListTileOverlay({
    super.key,
    required this.pointerKey,
    required this.onTapOutside,
  });

  final GlobalKey pointerKey;
  final VoidCallback onTapOutside;

  @override
  Widget build(BuildContext context) {
    return ConditionallyAbsorbPointer(
      callback: (position) {
        final renderBox =
            pointerKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) {
          return false;
        }
        final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
        if (rect.contains(position)) {
          return false;
        }
        onTapOutside();
        return true;
      },
    );
  }
}

class TodoListTile extends StatefulWidget {
  const TodoListTile({
    super.key,
    required this.contents,
    this.controller,
    this.focusNode,
    this.italic = false,
    this.underline = false,
    this.completed = false,
    this.selected = false,
    this.editable = false,
    this.editMode = false,
    this.onSubmit,
    this.onDelete,
    this.onTap,
    this.onLongPress,
  });

  const TodoListTile.create({
    Key? key,
    required String contents,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool editMode,
    VoidCallback? onTap,
    required ValueChanged<String> onSubmit,
  }) : this(
          key: key,
          editable: true,
          italic: true,
          underline: true,
          editMode: editMode,
          contents: contents,
          controller: controller,
          focusNode: focusNode,
          onTap: onTap,
          onSubmit: onSubmit,
        );

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final String contents;
  final bool italic;
  final bool underline;
  final bool completed;
  final bool selected;
  final bool editable;
  final bool editMode;

  final ValueChanged<String>? onSubmit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<TodoListTile> createState() => _TodoListTileState();
}

class _TodoListTileState extends State<TodoListTile> {
  @override
  Widget build(BuildContext context) {
    assert(
      !(widget.editMode &&
          (widget.controller == null || widget.focusNode == null)),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: widget.onLongPress,
      onTap: widget.onTap,
      child: TweenAnimationBuilder<Color?>(
        duration: animationDuration,
        tween: MyColorTween(
          begin: !widget.selected ? const Color(0x33BEB7EB) : Colors.white,
          end: widget.selected ? const Color(0x33BEB7EB) : Colors.white,
        ),
        builder: (context, value, child) {
          return Container(
            height: 41,
            color: value,
            child: child,
          );
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.completed
                      ? _taskCircleColorCompleted
                      : _taskCircleColor,
                ),
                child: const SizedBox.square(dimension: 16),
              ),
            ),
            Expanded(
              child: widget.editMode
                  ? EditableText(
                      controller: widget.controller!,
                      focusNode: widget.focusNode!,
                      onSubmitted: widget.onSubmit,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                      cursorColor: Colors.black,
                      cursorHeight: 14,
                      cursorWidth: 1,
                      backgroundCursorColor: Colors.black,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                    )
                  : AnimatedDefaultTextStyle(
                      duration: animationDuration,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        height: 21.82 / 16,
                        color: widget.completed
                            ? _taskTitleColorCompleted
                            : _taskTitleColor,
                        fontStyle: widget.italic ? FontStyle.italic : null,
                        decoration:
                            widget.underline ? TextDecoration.underline : null,
                      ),
                      child: Text(
                        widget.contents,
                        maxLines: 1,
                      ),
                    ),
            ),
            if (widget.selected)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.onDelete?.call(),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Удалить',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DatesCarousel extends StatelessWidget {
  const DatesCarousel({
    super.key,
    required this.selected,
    required this.onSelectedChanged,
    required this.loadTodoCallback,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelectedChanged;
  final void Function(DateTime dateTime) loadTodoCallback;

  DateTime _getDateTimeByIndex(int index) {
    if (!index.isNegative) {
      return DateTime.now().add(Duration(days: index));
    } else {
      return DateTime.now().subtract(Duration(days: index.abs()));
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: const Color(0xFFEDEBF9),
      child: InfiniteListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final date = _getDateTimeByIndex(index);
          final isSelected = _isSameDay(selected, date);

          loadTodoCallback(date);

          return GestureDetector(
            onTap: () => onSelectedChanged(date),
            child: Container(
              margin: const EdgeInsets.all(12),
              width: 40,
              child: TweenAnimationBuilder<Color>(
                duration: animationDuration,
                tween: MyColorTween(
                  begin: !isSelected ? _backColorS : _backColor,
                  end: isSelected ? _backColorS : _backColor,
                ),
                builder: (context, value, child) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: value,
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                    ),
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      if (_isSameDay(DateTime.now(), date))
                        const Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD9D9D9),
                            ),
                            child: SizedBox.square(dimension: 4),
                          ),
                        )
                      else
                        const Spacer(),
                      AnimatedDefaultTextStyle(
                        duration: animationDuration,
                        style: TextStyle(
                          fontSize: 14,
                          height: 16 / 14,
                          color: isSelected ? _dayColorS : _dayColor,
                        ),
                        child: Text('${date.day}'),
                      ),
                      const Gap(4),
                      AnimatedDefaultTextStyle(
                        duration: animationDuration,
                        style: TextStyle(
                          fontSize: 14,
                          height: 16 / 14,
                          color: isSelected ? _dayTextColorS : _dayTextColor,
                        ),
                        child: Text(
                          capitalizeWord(DateFormat('E').format(date)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
