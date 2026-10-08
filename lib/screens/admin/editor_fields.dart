import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

String adminErrorMessage(Object error) {
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' =>
        'You do not have permission to make this change. Sign in with the owner account.',
      'unavailable' || 'network-request-failed' =>
        'The service is unavailable. Check your connection and try again.',
      'not-found' =>
        'This item no longer exists. Close this editor and refresh the list.',
      'already-exists' => 'That link is already in use. Choose another slug.',
      _ => 'The change could not be saved. Please try again.',
    };
  }
  if (error is FormatException) return error.message;
  if (error is StateError) return error.message;
  return 'The change could not be completed. Please try again.';
}

class AdminTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final int maxLines;
  final int? maxLength;
  final String? helper;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const AdminTextField({
    super.key,
    required this.controller,
    required this.label,
    this.required = false,
    this.maxLines = 1,
    this.maxLength,
    this.helper,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'Enter $label.';
        }
        return validator?.call(value);
      },
    ),
  );
}

class AdminEditorDialog extends StatefulWidget {
  final String title;
  final List<Widget> fields;
  final Future<void> Function() onSave;
  final String? introduction;

  const AdminEditorDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
    this.introduction,
  });

  @override
  State<AdminEditorDialog> createState() => _AdminEditorDialogState();
}

class _AdminEditorDialogState extends State<AdminEditorDialog> {
  final _form = GlobalKey<FormState>();
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) {
      setState(() => _error = 'Check the marked fields before saving.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = adminErrorMessage(error);
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
        ],
      ),
      content: SizedBox(
        width: 660,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: AbsorbPointer(
              absorbing: _saving,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.introduction != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(widget.introduction!),
                    ),
                  ...widget.fields,
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    semanticsLabel: 'Saving',
                  ),
                )
              : const Text('Save'),
        ),
      ],
    ),
  );
}

class EditorSection extends StatelessWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  const EditorSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ExpansionTile(
      key: PageStorageKey(title),
      initiallyExpanded: initiallyExpanded,
      maintainState: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(top: 12),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      children: [child],
    ),
  );
}

class EditableRows<T extends Object> extends StatelessWidget {
  final List<T> rows;
  final String itemLabel;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int, int) onMove;
  final Widget Function(T, int) builder;
  final int maxItems;

  const EditableRows({
    super.key,
    required this.rows,
    required this.itemLabel,
    required this.onAdd,
    required this.onRemove,
    required this.onMove,
    required this.builder,
    this.maxItems = 12,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (rows.isEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('No ${itemLabel.toLowerCase()} entries yet.'),
        ),
      for (var i = 0; i < rows.length; i++)
        Card(
          key: ObjectKey(rows[i]),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$itemLabel ${i + 1}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Move $itemLabel ${i + 1} up',
                      onPressed: i == 0 ? null : () => onMove(i, i - 1),
                      icon: const Icon(Icons.arrow_upward, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Move $itemLabel ${i + 1} down',
                      onPressed: i == rows.length - 1
                          ? null
                          : () => onMove(i, i + 1),
                      icon: const Icon(Icons.arrow_downward, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Remove $itemLabel ${i + 1}',
                      onPressed: () => onRemove(i),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                builder(rows[i], i),
              ],
            ),
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: rows.length >= maxItems ? null : onAdd,
          icon: const Icon(Icons.add),
          label: Text('Add ${itemLabel.toLowerCase()}'),
        ),
      ),
    ],
  );
}

class _StringRow {
  String value;
  _StringRow(this.value);
}

class StringListEditor extends StatefulWidget {
  final List<String> initialValues;
  final String itemLabel;
  final ValueChanged<List<String>> onChanged;
  final int maxItems;
  final int itemMaxLength;
  final ValueChanged<int>? onRemove;
  final void Function(int, int)? onMove;
  const StringListEditor({
    super.key,
    required this.initialValues,
    required this.itemLabel,
    required this.onChanged,
    this.maxItems = 50,
    this.itemMaxLength = 2000,
    this.onRemove,
    this.onMove,
  });

  @override
  State<StringListEditor> createState() => _StringListEditorState();
}

class _StringListEditorState extends State<StringListEditor> {
  late final List<_StringRow> _rows = widget.initialValues
      .map(_StringRow.new)
      .toList();
  void _changed() =>
      widget.onChanged(_rows.map((row) => row.value.trim()).toList());

  @override
  Widget build(BuildContext context) => EditableRows<_StringRow>(
    rows: _rows,
    itemLabel: widget.itemLabel,
    maxItems: widget.maxItems,
    onAdd: () {
      setState(() => _rows.add(_StringRow('')));
      _changed();
    },
    onRemove: (index) {
      widget.onRemove?.call(index);
      setState(() => _rows.removeAt(index));
      _changed();
    },
    onMove: (from, to) {
      widget.onMove?.call(from, to);
      setState(() => _rows.insert(to, _rows.removeAt(from)));
      _changed();
    },
    builder: (row, index) => TextFormField(
      key: ObjectKey(row),
      initialValue: row.value,
      maxLength: widget.itemMaxLength,
      decoration: InputDecoration(
        labelText: widget.itemLabel,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Enter a value or remove this entry.'
          : null,
      onChanged: (value) {
        row.value = value;
        _changed();
      },
    ),
  );
}

class ContentChoice {
  final String id;
  final String label;
  final bool isActive;
  const ContentChoice({
    required this.id,
    required this.label,
    this.isActive = true,
  });
}

class OrderedContentPicker extends StatelessWidget {
  final String label;
  final List<ContentChoice> choices;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final bool emptyMeansAll;
  const OrderedContentPicker({
    super.key,
    required this.label,
    required this.choices,
    required this.selected,
    required this.onChanged,
    this.emptyMeansAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final byId = {for (final choice in choices) choice.id: choice};
    final remaining = choices
        .where((choice) => choice.isActive && !selected.contains(choice.id))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          selected.isEmpty
              ? (emptyMeansAll
                    ? 'All published items will appear in their display order.'
                    : 'No items selected for this link.')
              : 'Selected items appear in this order. Archived items stay hidden.',
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < selected.length; i++)
          Card(
            key: ValueKey(selected[i]),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    byId[selected[i]]?.label ??
                        'Unavailable item (${selected[i]})',
                  ),
                  if (byId[selected[i]] == null || !byId[selected[i]]!.isActive)
                    Text(
                      'Hidden publicly. Remove it here or restore it in the library.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip:
                            'Move ${byId[selected[i]]?.label ?? 'item'} up',
                        onPressed: i == 0
                            ? null
                            : () {
                                final ids = [...selected];
                                ids.insert(i - 1, ids.removeAt(i));
                                onChanged(ids);
                              },
                        icon: const Icon(Icons.arrow_upward, size: 18),
                      ),
                      IconButton(
                        tooltip:
                            'Move ${byId[selected[i]]?.label ?? 'item'} down',
                        onPressed: i == selected.length - 1
                            ? null
                            : () {
                                final ids = [...selected];
                                ids.insert(i + 1, ids.removeAt(i));
                                onChanged(ids);
                              },
                        icon: const Icon(Icons.arrow_downward, size: 18),
                      ),
                      IconButton(
                        tooltip: 'Remove ${byId[selected[i]]?.label ?? 'item'}',
                        onPressed: () {
                          final ids = [...selected]..removeAt(i);
                          onChanged(ids);
                        },
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (selected.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => onChanged([]),
              child: Text(
                emptyMeansAll ? 'Use all published items' : 'Clear selection',
              ),
            ),
          ),
        for (final choice in remaining)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(choice.label),
            value: false,
            onChanged: selected.length >= 100
                ? null
                : (_) => onChanged([...selected, choice.id]),
          ),
        if (choices.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Add content to your library first.'),
          ),
      ],
    );
  }
}

@Preview(
  name: 'Ordered content selection',
  group: 'Admin',
  size: Size(390, 680),
)
Widget orderedContentPreview() => MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: OrderedContentPicker(
        label: 'Featured work',
        choices: const [ContentChoice(id: 'example', label: 'Example project')],
        selected: const [],
        onChanged: (_) {},
        emptyMeansAll: true,
      ),
    ),
  ),
);
