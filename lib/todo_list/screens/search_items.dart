import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../../service_locator/service_locator.dart';
import '../controllers/todo_list_controller.dart';

class SearchItems extends StatelessWidget {
  const SearchItems({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: Container(
            padding: const EdgeInsets.only(left: 10.0),
            height: 45.0,
            margin: const EdgeInsets.only(right: 5.0, bottom: 5.0),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: TypeAheadField(
              suggestionsCallback: (pattern) {
                return getIt<TodoListController>()
                    .todoLists
                    .where((todo) => todo.title!
                        .toLowerCase()
                        .contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.title!),
                );
              },
              onSelected: (value) {
                debugPrint("on Selected:${value.title}");
                getIt<TodoListController>().onSearch(value.title);
              },
            ),
          ),
        ),
        body: Obx(
          () => getIt<TodoListController>().searchResults.isNotEmpty
              ? ListView.builder(
                  itemCount: getIt<TodoListController>().searchResults.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(getIt<TodoListController>()
                              .searchResults[index]
                              .title!),
                        ),
                        const Divider(), //                           <-- Divider
                      ],
                    );
                  })
              : Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No todo list yet"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Do you need add todo?"),
                        TextButton(
                          child: const Text("Add"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                )),
        ),
      ),
    );
  }
}
