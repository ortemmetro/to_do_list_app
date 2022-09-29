import 'package:hive/hive.dart';
import 'package:to_do_list_test_app/domain/entity/task.dart';

import '../entity/group.dart';

class BoxManager {
  static final BoxManager instance = BoxManager._();
  final Map<String, int> _boxCounter = <String, int>{};

  BoxManager._();

  Future<Box<Group>> openGroupBox() async{
    return _openBox("groups_box", 0, GroupAdapter());
  }

  Future<Box<Task>> openTaskBox(int groupKey) async{
    return _openBox(makeTaskBoxName(groupKey), 1, TaskAdapter());
  }

  Future<void> closeBox<T>(Box<T> box) async{
    if(!box.isOpen){
      _boxCounter.remove(box.name);
      return;
    }

    var count = _boxCounter[box.name] ?? 1;
    count -= 1;
    _boxCounter[box.name] = count;
    if(count > 0) return;

    _boxCounter.remove(box.name);
    await box.compact();
    await box.close();
  }


  String makeTaskBoxName(int groupKey) => 'tasks_box_$groupKey';

  Future<Box<T>> _openBox<T>(
      String boxName, int typeId, TypeAdapter<T> adapter) async {
    if(Hive.isBoxOpen(boxName)){
      final count = _boxCounter[boxName] ?? 1;
      _boxCounter[boxName] = count + 1;
      return Hive.box(boxName);
    }
    _boxCounter[boxName] = 1;
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
    }

    return Hive.openBox<T>(boxName);
  }


}
