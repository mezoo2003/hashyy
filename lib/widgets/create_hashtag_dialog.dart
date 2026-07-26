import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/models/hashtag.dart';
import '../l10n/app_strings.dart';
import '../providers/hashtag_provider.dart';
import 'color_picker_grid.dart';

/// Shows a dialog to create a new hashtag. Returns the created [Hashtag],
/// or null if the user cancelled.
Future<Hashtag?> showCreateHashtagDialog(BuildContext context) {
  return showDialog<Hashtag>(
    context: context,
    builder: (_) => const CreateHashtagDialog(),
  );
}

class CreateHashtagDialog extends StatefulWidget {
  const CreateHashtagDialog({super.key});

  @override
  State<CreateHashtagDialog> createState() => _CreateHashtagDialogState();
}

class _CreateHashtagDialogState extends State<CreateHashtagDialog> {
  final _nameController = TextEditingController();
  final _passController = TextEditingController();
  final _passConfirmController = TextEditingController();
  late String _color;
  bool _locked = false;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _color = context.read<HashtagProvider>().randomColor();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passController.dispose();
    _passConfirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (_locked) {
      if (_passController.text.length < 4) {
        setState(() => _error = context.tr('passwordTooShort'));
        return;
      }
      if (_passController.text != _passConfirmController.text) {
        setState(() => _error = context.tr('passwordsDontMatch'));
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final provider = context.read<HashtagProvider>();
    try {
      final hashtag = await provider.create(
        name: name,
        colorHex: _color,
        isLocked: _locked,
        rawPassword: _locked ? _passController.text : null,
      );
      if (mounted) Navigator.pop(context, hashtag);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = context.tr('somethingWentWrong');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('createHashtag')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: context.tr('hashtagName'),
                hintText: context.tr('hashtagNameHint'),
                prefixText: '#',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 18),
            Text(context.tr('selectColor'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ColorPickerGrid(selectedHex: _color, onSelect: (c) => setState(() => _color = c)),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _locked,
              onChanged: (v) => setState(() => _locked = v),
              title: Text(context.tr('lockThisHashtag')),
              activeColor: AppColors.primary,
            ),
            if (_locked) ...[
              const SizedBox(height: 4),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(labelText: context.tr('password')),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passConfirmController,
                obscureText: true,
                decoration: InputDecoration(labelText: context.tr('confirmPassword')),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!, style: const TextStyle(color: AppColors.error)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(context.tr('create')),
        ),
      ],
    );
  }
}
