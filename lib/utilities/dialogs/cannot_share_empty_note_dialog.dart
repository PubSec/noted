import 'package:flutter/material.dart';
import 'package:noted/utilities/dialogs/generic_dialogs.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You can\'t share empty note.',
    optionBuilder: () => {
      'OK': null,
    },
  );
}
