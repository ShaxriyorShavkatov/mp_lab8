import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  double _fontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 14.0;
    });
  }

  void updateTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void updateFontSize(double size) {
    setState(() {
      _fontSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Persistence Demo',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        fontSize: _fontSize,
        onThemeChanged: updateTheme,
        onFontSizeChanged: updateFontSize,
      ),
      routes: {
        '/note-detail': (context) => const NoteDetailScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final bool isDarkMode;
  final double fontSize;
  final Function(bool) onThemeChanged;
  final Function(double) onFontSizeChanged;

  const HomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.fontSize,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Persistence Tasks'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTaskCard(
            context,
            'Task 1-3: SharedPreferences',
            'Username, Counter, Dark Mode',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SharedPreferencesScreen(
                  isDarkMode: isDarkMode,
                  fontSize: fontSize,
                  onThemeChanged: onThemeChanged,
                  onFontSizeChanged: onFontSizeChanged,
                ),
              ),
            ),
          ),
          _buildTaskCard(
            context,
            'Task 4-8: SQLite CRUD',
            'Notes Database Operations',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotesListScreen()),
            ),
          ),
          _buildTaskCard(
            context,
            'Task 9: File Storage',
            'Read/Write Text Files',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FileStorageScreen()),
            ),
          ),
          _buildTaskCard(
            context,
            'Task 10: Hybrid Storage',
            'Settings + Notes Combined',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HybridStorageScreen(
                  isDarkMode: isDarkMode,
                  fontSize: fontSize,
                  onThemeChanged: onThemeChanged,
                  onFontSizeChanged: onFontSizeChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

// PART A: SHARED PREFERENCES (Tasks 1-3)
class SharedPreferencesScreen extends StatefulWidget {
  final bool isDarkMode;
  final double fontSize;
  final Function(bool) onThemeChanged;
  final Function(double) onFontSizeChanged;

  const SharedPreferencesScreen({
    Key? key,
    required this.isDarkMode,
    required this.fontSize,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
  }) : super(key: key);

  @override
  State<SharedPreferencesScreen> createState() => _SharedPreferencesScreenState();
}

class _SharedPreferencesScreenState extends State<SharedPreferencesScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String _savedUsername = '';
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUsername = prefs.getString('username') ?? 'No username saved';
      _counter = prefs.getInt('counter') ?? 0;
    });
  }

  Future<void> _saveUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Username saved!')),
    );
  }

  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter++;
    });
    await prefs.setInt('counter', _counter);
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    widget.onThemeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SharedPreferences Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Task 1: Save Username', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Enter username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saveUsername,
              child: const Text('Save Username'),
            ),
            Text('Saved Username: $_savedUsername', style: const TextStyle(fontSize: 16)),
            const Divider(height: 32),
            const Text('Task 2: Counter Persistence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Counter: $_counter', style: const TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text('Increment Counter'),
            ),
            const Divider(height: 32),
            const Text('Task 3: Dark Mode Toggle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: widget.isDarkMode,
              onChanged: _toggleDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}

// DATABASE HELPER
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertNote(Map<String, dynamic> note) async {
    final db = await database;
    return await db.insert('notes', note);
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'id DESC');
  }

  Future<int> updateNote(int id, Map<String, dynamic> note) async {
    final db = await database;
    return await db.update('notes', note, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

// PART B & C: SQLITE (Tasks 4-8)
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await DatabaseHelper.instance.getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addDummyNote() async {
    await DatabaseHelper.instance.insertNote({
      'title': 'Note ${DateTime.now().millisecondsSinceEpoch}',
      'content': 'This is a dummy note created at ${DateTime.now()}',
    });
    _loadNotes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note added!')),
    );
  }

  Future<void> _deleteNote(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteNote(id);
      _loadNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted!')),
      );
    }
  }

  void _navigateToDetail(Map<String, dynamic>? note) async {
    final result = await Navigator.pushNamed(
      context,
      '/note-detail',
      arguments: note,
    );
    if (result == true) {
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addDummyNote,
            tooltip: 'Add Dummy Note',
          ),
        ],
      ),
      body: _notes.isEmpty
          ? const Center(child: Text('No notes yet. Add one!'))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(note['title']),
                    subtitle: Text(
                      note['content'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToDetail(note),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteNote(note['id']),
                        ),
                      ],
                    ),
                    onTap: () => _navigateToDetail(note),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetail(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// TASK 8: Detail Screen with Navigation
class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({Key? key}) : super(key: key);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  int? _noteId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final note = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (note != null) {
      _noteId = note['id'];
      _titleController.text = note['title'];
      _contentController.text = note['content'];
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final noteData = {
      'title': _titleController.text,
      'content': _contentController.text,
    };

    if (_noteId == null) {
      await DatabaseHelper.instance.insertNote(noteData);
    } else {
      await DatabaseHelper.instance.updateNote(_noteId!, noteData);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_noteId == null ? 'Add Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

// PART D: FILE STORAGE (Task 9)
class FileStorageScreen extends StatefulWidget {
  const FileStorageScreen({Key? key}) : super(key: key);

  @override
  State<FileStorageScreen> createState() => _FileStorageScreenState();
}

class _FileStorageScreenState extends State<FileStorageScreen> {
  final TextEditingController _textController = TextEditingController();
  String _fileContent = '';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/user_data.txt');
  }

  Future<void> _writeFile() async {
    final file = await _localFile;
    await file.writeAsString(_textController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File saved!')),
    );
  }

  Future<void> _readFile() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      setState(() {
        _fileContent = contents;
      });
    } catch (e) {
      setState(() {
        _fileContent = 'Error reading file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Storage Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter text to save',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _writeFile,
              child: const Text('Write to File'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _readFile,
              child: const Text('Read from File'),
            ),
            const SizedBox(height: 16),
            const Text('File Content:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_fileContent.isEmpty ? 'No content yet' : _fileContent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

// TASK 10: HYBRID STORAGE
class HybridStorageScreen extends StatefulWidget {
  final bool isDarkMode;
  final double fontSize;
  final Function(bool) onThemeChanged;
  final Function(double) onFontSizeChanged;

  const HybridStorageScreen({
    Key? key,
    required this.isDarkMode,
    required this.fontSize,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
  }) : super(key: key);

  @override
  State<HybridStorageScreen> createState() => _HybridStorageScreenState();
}

class _HybridStorageScreenState extends State<HybridStorageScreen> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final notes = await DatabaseHelper.instance.getAllNotes();
    setState(() {
      _tasks = notes;
    });
  }

  Future<void> _saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    widget.onFontSizeChanged(size);
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    widget.onThemeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hybrid Storage Demo')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Settings (SharedPreferences)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: widget.isDarkMode,
                  onChanged: _toggleTheme,
                ),
                ListTile(
                  title: const Text('Font Size'),
                  subtitle: Slider(
                    value: widget.fontSize,
                    min: 10,
                    max: 24,
                    divisions: 14,
                    label: widget.fontSize.round().toString(),
                    onChanged: _saveFontSize,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tasks/Notes (SQLite)',
              style: TextStyle(fontSize: widget.fontSize + 4, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No tasks yet'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return ListTile(
                        title: Text(task['title'], style: TextStyle(fontSize: widget.fontSize)),
                        subtitle: Text(task['content'], style: TextStyle(fontSize: widget.fontSize - 2)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}