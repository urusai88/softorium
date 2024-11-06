import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:intl/intl.dart';
import 'package:time/time.dart';

import '../../../../data.dart';
import '../../../../domain.dart';
import '../../../../presentation.dart';
import '../../../../services.dart';

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

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();

  late DateTime _selected;

  final _pointerKey = GlobalKey();

  int? _selectedTodoId;

  bool _editMode = false;

  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    _selected = DateTime.now();
  }

  TodosProvider _todosProvider(DateTime date) =>
      todosProvider(Todo.dateFormat.format(date));

  TodosNotifier _todosNotifier(DateTime date) =>
      ref.read(_todosProvider(date).notifier);

  TodosState _todos(DateTime date) => ref.watch(_todosProvider(date));

  Future<void> _addTodo(String value) async {
    _entry?.remove();
    _entry = null;
    await _todosNotifier(_selected).createTodo(value);
    setState(() => _editMode = false);
    _focusNode.unfocus();
    _textEditingController.clear();
  }

  void _onBeginEdit() {
    setState(() {
      _editMode = true;
      _selectedTodoId = null;
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
    _entry = OverlayEntry(
      builder: (_) => TapOutsideOverlay(
        keys: [_pointerKey],
        onTapOutside: () => unawaited(_addTodo(_textEditingController.text)),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(30));

    final result = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DatesCarousel(
          selected: _selected,
          onSelectedChanged: (v) => setState(() => _selected = v),
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
                Flexible(
                  child: _todos(_selected).maybeWhen(
                    data: (todos) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DayLabel(dateTime: _selected),
                          const Gap(20),
                          Flexible(
                            child: CustomScrollView(
                              key: _pointerKey,
                              shrinkWrap: true,
                              slivers: [
                                SliverList.builder(
                                  itemCount: todos.length,
                                  itemBuilder: (context, index) {
                                    final todo = todos[index];
                                    return TodoListTile(
                                      key: Key('todo-${todo.id}'),
                                      contents: todo.description,
                                      completed: todo.completed,
                                      selected: _selectedTodoId == todo.id,
                                      onTap: () {
                                        if (_editMode) {
                                          unawaited(
                                            _addTodo(
                                              _textEditingController.text,
                                            ),
                                          );
                                        } else {
                                          setState(
                                            () {
                                              if (_selectedTodoId == todo.id) {
                                                _selectedTodoId = null;
                                              } else {
                                                _selectedTodoId = todo.id;
                                              }
                                            },
                                          );
                                        }
                                      },
                                      onLongPress: () async =>
                                          _todosNotifier(_selected).updateTodo(
                                        todo.id,
                                        completed: true,
                                      ),
                                      onDelete: () => unawaited(
                                        _todosNotifier(_selected)
                                            .deleteTodo(todo.id),
                                      ),
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
                      );
                    },
                    orElse: () {
                      return const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Gap(6),
                          Center(child: CircularProgressIndicator()),
                        ],
                      );
                    },
                  ),
                ),
                const Gap(14),
              ],
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: pagePadding,
      child: Align(
        alignment: Alignment.topCenter,
        child: ClipRRect(
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
            child: result,
          ),
        ),
      ),
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
      child: MyAnimatedColor(
        duration: animationDuration,
        color: widget.selected ? const Color(0x33BEB7EB) : Colors.white,
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
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: const Color(0xFFEDEBF9),
      child: InfiniteListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final date = DateTime.now() + index.days;
          return DayListTile(
            dateTime: date,
            selected: selected.isAtSameDayAs(date),
            onTap: () => onSelectedChanged(date),
          );
        },
      ),
    );
  }
}

class DayListTile extends StatelessWidget {
  const DayListTile({
    super.key,
    required this.dateTime,
    required this.selected,
    this.onTap,
  });

  final DateTime dateTime;
  final bool selected;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final result = MyAnimatedColor(
      duration: animationDuration,
      color: selected ? _backColorS : _backColor,
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
            if (DateTime.now().isAtSameDayAs(dateTime))
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
                color: selected ? _dayColorS : _dayColor,
              ),
              child: Text('${dateTime.day}'),
            ),
            const Gap(4),
            AnimatedDefaultTextStyle(
              duration: animationDuration,
              style: TextStyle(
                fontSize: 14,
                height: 16 / 14,
                color: selected ? _dayTextColorS : _dayTextColor,
              ),
              child: Text(
                capitalizeWord(DateFormat('E').format(dateTime)),
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: result,
      ),
    );
  }
}

class DayLabel extends StatelessWidget {
  const DayLabel({
    super.key,
    required this.dateTime,
  });

  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Text(
      'План на день ${DateFormat('dd.MM.yyyy').format(dateTime)}',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        height: 24 / 14,
        color: Colors.black,
      ),
    );
  }
}
