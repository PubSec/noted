import 'package:flutter/material.dart';
import 'package:noted/utilities/dialogs/generic_dialogs.dart';

Future<void> showPasswordResetDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Password Reset',
      content: 'Link sent to email.',
      optionBuilder: () => {
            'Ok': null,
          });
}
