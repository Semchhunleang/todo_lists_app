import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list_app/todo_list/controllers/todo_list_controller.dart';
import 'package:todo_list_app/todo_list/screens/search_items.dart';

import '../../service_locator/service_locator.dart';
import '../widgets/custom_card_todo.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    getIt<TodoListController>().onFetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        title: const Text(
          "Todo List Screen",
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchItems()),
                  );
                },
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 30.0,
                )),
          )
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 30.0),
          child: SingleChildScrollView(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          //initialValue: null,
                          controller: getIt<TodoListController>()
                              .taskTodoController
                              .value,
                          decoration: const InputDecoration(
                            hintText: 'Enter a task',
                          ),
                          onFieldSubmitted: (value) {
                            getIt<TodoListController>().onValidateEmpty();

                            debugPrint("on insert start");
                            if (getIt<TodoListController>().isUpdate.value ==
                                true) {
                              // update items
                              // getIt<TodoListController>().onUpdate();
                              getIt<TodoListController>().onUpdateToFirebase();
                            } else {
                              debugPrint("insert item to list");
                              // insert items to list
                              // getIt<TodoListController>().onAddItems();
                              getIt<TodoListController>().onInsert();
                            }
                          },
                          onChanged: (value) {
                            getIt<TodoListController>().validateEmpty.value =
                                false;
                            // getIt<TodoListController>()
                            //     .onValidateEmpty(value: value);
                            getIt<TodoListController>()
                                .validateDuplicate
                                .value = false;
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          getIt<TodoListController>().onValidateEmpty();

                          debugPrint("on insert start");
                          if (getIt<TodoListController>().isUpdate.value ==
                              true) {
                            // update items
                            // getIt<TodoListController>().onUpdate();
                            getIt<TodoListController>().onUpdateToFirebase();
                          } else {
                            debugPrint("insert item to list");
                            // insert items to list
                            // getIt<TodoListController>().onAddItems();
                            getIt<TodoListController>().onInsert();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(13.0),
                          decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Text(
                            getIt<TodoListController>().isUpdate.value
                                ? "Update"
                                : "Add",
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  if (getIt<TodoListController>().validateEmpty.value ||
                      getIt<TodoListController>().validateDuplicate.value)
                    Text(
                      getIt<TodoListController>().validateDuplicate.value
                          ? "This item already has, please try another one."
                          : "Please input item, there should not be empty.",
                      style: const TextStyle(
                          color: Colors.red, fontSize: 12, fontFamily: ''),
                    ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  if (getIt<TodoListController>().todoLists.isNotEmpty)
                    Column(
                      children: getIt<TodoListController>()
                          .todoLists
                          .asMap()
                          .entries
                          .map((e) {
                        final tasks =
                            getIt<TodoListController>().todoLists[e.key];
                        return CustomCardTodo(
                          label: e.value.title,
                          isComplete: tasks.isComplete,
                          onTapDelete: () {
                            //Do on delete item in the list widget
                            //getIt<TodoListController>().onDeleteItems(e.key);
                            getIt<TodoListController>()
                                .onDeleteItemsFromDatabase(e.value.itemKey!);
                          },
                          onTapEdit: () {
                            // Do on edit item in the list widget
                            getIt<TodoListController>()
                                .taskTodoController
                                .value
                                .text = e.value.title!;
                            getIt<TodoListController>().itemKeys.value =
                                e.value.itemKey!;
                            getIt<TodoListController>().indextItems.value =
                                e.key;
                            getIt<TodoListController>().isUpdate.value = true;
                            getIt<TodoListController>().validateEmpty.value =
                                false;
                            getIt<TodoListController>()
                                .validateDuplicate
                                .value = false;
                          },
                          onTapComplete: () {
                            getIt<TodoListController>().onMarkComplete(e.key);
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
