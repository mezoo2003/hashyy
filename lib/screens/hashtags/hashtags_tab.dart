import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/hashtag.dart';
import '../../l10n/app_strings.dart';
import '../../providers/hashtag_provider.dart';
import '../../widgets/color_picker_grid.dart';
import '../../widgets/create_hashtag_dialog.dart';
import '../../widgets/empty_state.dart';
import '../unlock/unlock_screen.dart';
import 'hashtag_detail_screen.dart';

class HashtagsTab extends StatelessWidget {
  const HashtagsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HashtagProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('hashtags'))),
      body: hp.loading && hp.hashtags.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : hp.hashtags.isEmpty
              ? EmptyState(
                  icon: Icons.local_offer_outlined,
                  title: context.tr('noHashtagsYet'),
                  subtitle: context.tr('noHashtagsYetDesc'),
                  action: ElevatedButton.icon(
                    onPressed: () => showCreateHashtagDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text(context.tr('createFirstHashtag')),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  itemCount: hp.hashtags.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final h = hp.hashtags[i];
                    final count = hp.photoCounts[h.id] ?? 0;
                    return _HashtagTile(hashtag: h, count: count);
                  },
                ),
      floatingActionButton: hp.hashtags.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => showCreateHashtagDialog(context),
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _HashtagTile extends StatelessWidget {
  final Hashtag hashtag;
  final int count;
  const _HashtagTile({required this.hashtag, required this.count});

  Future<void> _open(BuildContext context) async {
    final hp = context.read<HashtagProvider>();
    if (hashtag.isLocked && !hp.isUnlocked(hashtag)) {
      final unlocked = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => UnlockScreen(hashtag: hashtag)),
      );
      if (unlocked != true) return;
    }
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HashtagDetailScreen(hashtag: hashtag)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(hashtag.colorHex);
    return Card(
      child: ListTile(
        onTap: () => _open(context),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(hashtag.isLocked ? Icons.lock : Icons.tag, color: color),
        ),
        title: Row(
          children: [
            if (hashtag.isPinned)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.push_pin, size: 14, color: AppColors.textSecondary),
              ),
            Flexible(
              child: Text(
                '#${hashtag.name}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        subtitle: Text('$count ${context.tr('photosLabel')}'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) => _handleMenu(context, v),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'pin',
              child: Text(hashtag.isPinned ? context.tr('unpinHashtag') : context.tr('pinHashtag')),
            ),
            PopupMenuItem(value: 'rename', child: Text(context.tr('rename'))),
            PopupMenuItem(value: 'color', child: Text(context.tr('colorLabel'))),
            PopupMenuItem(
              value: 'lock',
              child: Text(hashtag.isLocked ? context.tr('unlock') : context.tr('lockThisHashtag')),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(context.tr('delete'), style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMenu(BuildContext context, String action) async {
    switch (action) {
      case 'pin':
        await context.read<HashtagProvider>().togglePin(hashtag);
        break;
      case 'rename':
        await _showRenameDialog(context, hashtag);
        break;
      case 'color':
        await _showColorDialog(context, hashtag);
        break;
      case 'lock':
        await _showLockDialog(context, hashtag);
        break;
      case 'delete':
        await _confirmDelete(context, hashtag);
        break;
    }
  }
}

Future<void> _showRenameDialog(BuildContext context, Hashtag hashtag) async {
  final controller = TextEditingController(text: hashtag.name);
  final newName = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.tr('renameHashtag')),
      content: TextField(
        controller: controller,
        autofocus: true,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(prefixText: '#', labelText: context.tr('hashtagName')),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(context.tr('cancel'))),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
          child: Text(context.tr('save')),
        ),
      ],
    ),
  );
  if (newName != null && newName.isNotEmpty && newName != hashtag.name && context.mounted) {
    await context.read<HashtagProvider>().rename(hashtag, newName);
  }
}

Future<void> _showColorDialog(BuildContext context, Hashtag hashtag) async {
  String selected = hashtag.colorHex;
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(context.tr('selectColor')),
        content: ColorPickerGrid(selectedHex: selected, onSelect: (c) => setState(() => selected = c)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, selected),
            child: Text(context.tr('save')),
          ),
        ],
      ),
    ),
  );
  if (result != null && context.mounted) {
    await context.read<HashtagProvider>().setColor(hashtag, result);
  }
}

Future<void> _showLockDialog(BuildContext context, Hashtag hashtag) async {
  final hp = context.read<HashtagProvider>();
  if (hashtag.isLocked) {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => UnlockScreen(hashtag: hashtag)),
    );
    if (ok == true) {
      await hp.setLock(hashtag, locked: false);
    }
    return;
  }

  final password = await showDialog<String>(
    context: context,
    builder: (_) => const _SetPasswordDialog(),
  );
  if (password != null && password.isNotEmpty) {
    await hp.setLock(hashtag, locked: true, rawPassword: password);
  }
}

Future<void> _confirmDelete(BuildContext context, Hashtag hashtag) async {
  final hp = context.read<HashtagProvider>();
  if (hashtag.isLocked) {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => UnlockScreen(hashtag: hashtag)),
    );
    if (ok != true) return;
  }
  if (!context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.tr('confirmDeleteTitle')),
      content: Text(context.tr('deleteHashtagConfirm')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(context.tr('cancel'))),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(context.tr('delete'), style: const TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await hp.delete(hashtag);
  }
}

class _SetPasswordDialog extends StatefulWidget {
  const _SetPasswordDialog();

  @override
  State<_SetPasswordDialog> createState() => _SetPasswordDialogState();
}

class _SetPasswordDialogState extends State<_SetPasswordDialog> {
  final _p1 = TextEditingController();
  final _p2 = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  void _submit() {
    if (_p1.text.length < 4) {
      setState(() => _error = context.tr('passwordTooShort'));
      return;
    }
    if (_p1.text != _p2.text) {
      setState(() => _error = context.tr('passwordsDontMatch'));
      return;
    }
    Navigator.pop(context, _p1.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('setPassword')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _p1,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(labelText: context.tr('password')),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _p2,
            obscureText: true,
            decoration: InputDecoration(labelText: context.tr('confirmPassword')),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: const TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
        ElevatedButton(onPressed: _submit, child: Text(context.tr('save'))),
      ],
    );
  }
}
