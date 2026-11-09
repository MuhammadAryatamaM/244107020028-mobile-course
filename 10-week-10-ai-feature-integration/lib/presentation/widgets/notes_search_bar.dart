import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notes_providers.dart';

class NotesSearchBar extends ConsumerStatefulWidget {
  const NotesSearchBar({super.key});

  @override
  ConsumerState<NotesSearchBar> createState() => _NotesSearchBarState();
}

class _NotesSearchBarState extends ConsumerState<NotesSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    if (_controller.text != query) {
      _controller.text = query;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Cari judul note…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).update(value);
        },
      ),
    );
  }
}
