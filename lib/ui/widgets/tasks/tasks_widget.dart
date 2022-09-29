import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:to_do_list_test_app/ui/widgets/tasks/tasks_widget_model.dart';

class TasksWidgetConfiguration {
  final int groupKey;
  final String title;

  TasksWidgetConfiguration(this.groupKey, this.title);
}

class TasksWidget extends StatefulWidget {
  final TasksWidgetConfiguration configuration;
  const TasksWidget({
    super.key,
    required this.configuration,
  });

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  late final TasksWidgetModel _model;

  @override
  void initState() {
    super.initState();
    _model = TasksWidgetModel(configuration: widget.configuration);
  }

  @override
  Widget build(BuildContext context) {
    return TasksWidgetModelProvider(
      model: _model,
      child: const TasksWidgetBody(),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _model.dispose();
  }
}

class TasksWidgetBody extends StatelessWidget {
  const TasksWidgetBody({super.key});

  @override
  Widget build(BuildContext context) {
    final model = TasksWidgetModelProvider.watch(context)?.model;
    final title = model?.configuration.title ?? "Задачи";
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: const _TaskListWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => model?.showForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskListWidget extends StatelessWidget {
  const _TaskListWidget();

  @override
  Widget build(BuildContext context) {
    final tasksLength =
        TasksWidgetModelProvider.watch(context)?.model.tasks.length ?? 0;
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return _TaskListRowWidget(index: index);
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(height: 1);
      },
      itemCount: tasksLength,
    );
  }
}

class _TaskListRowWidget extends StatelessWidget {
  final int index;
  const _TaskListRowWidget({
    required this.index,
  });

  void doNothing(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    final model = TasksWidgetModelProvider.read(context)!.model;
    final task = model.tasks[index];
    final icon = task.isDone ? const Icon(Icons.done) : null;
    final textStyle = task.isDone
        ? const TextStyle(decoration: TextDecoration.lineThrough)
        : null;
    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.23,
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => model.deleteTask(index),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          task.text,
          style: textStyle,
        ),
        trailing: icon,
        onTap: () => model.doneToggle(index),
      ),
    );
  }
}
