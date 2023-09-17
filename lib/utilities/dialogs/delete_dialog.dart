import 'package:flutter/material.dart';
import 'package:noted/utilities/dialogs/generic_dialogs.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this item?',
    optionBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
