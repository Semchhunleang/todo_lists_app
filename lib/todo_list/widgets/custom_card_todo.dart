import 'package:flutter/material.dart';

class CustomCardTodo extends StatelessWidget {
  final String? label;
  final GestureTapCallback? onTapDelete;
  final GestureTapCallback? onTapEdit;
  final GestureTapCallback? onTapComplete;
  final bool isComplete;
  const CustomCardTodo(
      {super.key,
      this.label,
      this.onTapDelete,
      this.onTapEdit,
      this.onTapComplete,
      this.isComplete = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 10.0),
              alignment: Alignment.centerLeft,
              width: double.infinity,
              height: 60.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xffEBEBEB),
                      blurRadius: 0.5,
                      spreadRadius: 0.5)
                ],
              ),
              child: Row(
                children: [
                  Text(
                    label == null ? "" : "$label",
                    style: TextStyle(
                        decoration:
                            isComplete ? TextDecoration.lineThrough : null),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onTapComplete,
                    icon: Icon(
                      isComplete
                          ? Icons.check_circle_outline
                          : Icons.circle_outlined,
                      color: isComplete ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onTapEdit,
            icon: const Icon(
              Icons.edit,
              color: Colors.deepPurple,
            ),
          ),
          IconButton(
            onPressed: onTapDelete,
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
