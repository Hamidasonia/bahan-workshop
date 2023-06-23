import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled/database_helper.dart';
import 'package:untitled/db_provider.dart';
import 'package:untitled/note.dart';
import 'package:untitled/note_add_update_page.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({Key? key}) : super(key: key);

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  late List<Note> noteList;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    noteList = [];
    _startTimer();
  }

  void _startTimer() {
    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (Timer timer) {
      _refreshPage();
    });
  }

  void _refreshPage() {
    setState(() {
      updateListView();
    });
  }

  Future<void> updateListView() async {
    final Future<Database> dbFuture = databaseHelper.initializeDb();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNotes();
      noteListFuture.then((noteList) {
        setState(
          () {
            this.noteList = noteList;
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: Provider<DbProvider>(
        create: (_) => DbProvider(),
        builder: (context, child) {
          final notes = Provider.of<DbProvider>(context, listen: false);

          return noteList.isEmpty
              ? Container()
              : ListView.builder(
                  itemCount: noteList.length,
                  itemBuilder: (context, index) {
                    final note = noteList[index];
                    return Dismissible(
                      key: Key(note.id.toString()),
                      background: Container(color: Colors.red),
                      onDismissed: (direction) {
                        // TODO : Kode untuk menghapus note
                        notes.deleteNote(note.id!);
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(note.title),
                          subtitle: Text(note.description),
                          onTap: () async {
                            // TODO : Kode untuk mendapatkan note yang dipilih dan dikirimkan ke NoteAddUpdatePage
                            final navigator = Navigator.of(context);

                            final selectedNote =
                                await notes.getNoteById(note.id!);

                            navigator.push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return NoteAddUpdatePage(
                                    note: selectedNote,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NoteAddUpdatePage()));
        },
      ),
    );
  }
}
