// ignore_for_file: deprecated_member_use
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../models/todo_model.dart';

class TodoListController extends GetxController {
  @factoryMethod
  static init() => Get.put(TodoListController());
  final taskTodoController = TextEditingController().obs;
  final taskTodoValue = "".obs;
  final itemKeys = "".obs;
  final todoLists = <TodoClass>[].obs;
  final formKey = GlobalKey<FormState>();
  final validateEmpty = false.obs;
  final validateDuplicate = false.obs;
  final indextItems = 0.obs;
  final isUpdate = false.obs;
  final isComplete = false.obs;
  TodoClass todoModel = TodoClass();

  // ----- Add item to list without firebase-------
  onAddItems() {
    var uuid = const Uuid();
    final String itemId = uuid.v4();

    taskTodoValue.value = taskTodoController.value.text;
    // check empty item
    if (!validateEmpty.value) {
      // check already item
      if (todoLists.any((item) =>
          item.title!.toLowerCase() == taskTodoValue.value.toLowerCase())) {
        validateDuplicate.value = true;
      } else {
        validateDuplicate.value = false;
        todoLists.add(TodoClass(id: itemId, title: taskTodoValue.value));
      }
    } else {
      validateDuplicate.value = false;
    }

    taskTodoController.value.clear();
    update();
  }

  // ----- for add data to firebase ------
  Future<void> onInsert() async {
    var uuid = const Uuid();
    final String itemId = uuid.v4();

    taskTodoValue.value = taskTodoController.value.text;
    if (!validateEmpty.value) {
      // check already item
      if (todoLists.any((item) =>
          item.title!.toLowerCase() == taskTodoValue.value.toLowerCase())) {
        validateDuplicate.value = true;
      } else {
        validateDuplicate.value = false;
        //Add to firebase
        DatabaseReference databaseReference =
            FirebaseDatabase.instance.reference().child('todo');

        databaseReference.push().set({
          'id': itemId,
          'title': taskTodoValue.value,
        });
        onFetchData();
      }
    } else {
      validateDuplicate.value = false;
    }
    taskTodoController.value.clear();
  }

  List<String> keyList = [];
  Future<void> onFetchData() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    keyList.clear();
    // Option 1: Using children keys
    final itemsRef = databaseReference.child('todo');

    itemsRef.once().then((snapshot) {
      final keys = snapshot.snapshot.children.map((item) => item.key).toList();

      for (var key in keys) {
        keyList.add(key.toString());
      }

      debugPrint(keyList.length.toString());
    }).then((value) => {onFetchListTodo()});
  }

  Future<void> onFetchListTodo() async {
    // final databaseReference = FirebaseDatabase.instance.reference();
    todoLists.clear();

    keyList.asMap().entries.map((e) async {
      debugPrint(e.value);
      DatabaseReference ref = FirebaseDatabase.instance.ref("todo/${e.value}");

      DatabaseEvent event = await ref.once();

      Map<dynamic, dynamic> snapshotData = event.snapshot.value as dynamic;

      todoLists.add(TodoClass(
          id: snapshotData["id"],
          title: snapshotData["title"],
          itemKey: e.value));
    }).toList();
    todoLists.reversed;
    return;
  }

  // ------ update data with firebase ------
  onUpdateToFirebase() async {
    if (!validateEmpty.value) {
      // check already item
      if (todoLists.any((item) =>
          item.title!.toLowerCase() == taskTodoValue.value.toLowerCase())) {
        validateDuplicate.value = true;
      } else {
        validateDuplicate.value = false;
        todoLists.clear();

        DatabaseReference ref =
            FirebaseDatabase.instance.ref("todo/${itemKeys.value}");

// Only update the name, leave the age and address!

        await ref.update({
          "title": taskTodoValue.value,
        });
        onFetchData();
        isUpdate.value = false;
        taskTodoValue.value = "";
        taskTodoController.value.clear();
      }
    }
  }

  // ----- update item without firebase -----
  onUpdate() {
    // check on empty item
    if (!validateEmpty.value) {
      todoLists[indextItems.value].title = taskTodoValue.value;
      isUpdate.value = false;
      taskTodoValue.value = "";
      taskTodoController.value.clear();
      todoLists.refresh();
    }
  }

  //Delete item in list
  onDeleteItems(int index) {
    todoLists.removeAt(index);
  }

  // On search item
  final searchResults = <TodoClass>[].obs;
  final searchCon = TextEditingController().obs;
  final isSearching = false.obs;
  onSearch(searchItems) {
    for (TodoClass data in todoLists) {
      if (data.title!.contains(searchItems)) {
        searchResults.add(data);
        searchResults.refresh();
        update();
      }
    }
  }

  onSearchListExampleState() {
    searchCon.value.addListener(() {
      if (searchCon.value.text.isEmpty) {
        isSearching.value = false;

        update();
      } else {
        isSearching.value = true;

        update();
      }
    });
  }

  //Validate empty item
  onValidateEmpty({String value = ""}) {
    if (value == "") {
      taskTodoValue.value = taskTodoController.value.text;
      if (taskTodoValue.value.isEmpty || taskTodoValue.value == " ") {
        validateEmpty.value = true;
      } else {
        validateEmpty.value = false;
      }
    } else {
      taskTodoValue.value = value;
      if (taskTodoValue.value.isEmpty || taskTodoValue.value == " ") {
        validateEmpty.value = true;
      } else {
        validateEmpty.value = false;
      }
    }
  }

  // Mark item as complete and incomplete
  onMarkComplete(int index) {
    todoLists[index].isComplete = !todoLists[index].isComplete;
    todoLists.refresh();
  }
}
