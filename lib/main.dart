




import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localuizationinflutterapp/app_localizations.dart';
import 'package:localuizationinflutterapp/languageProvider.dart';
import 'package:localuizationinflutterapp/locale_constants.dart';
import 'package:localuizationinflutterapp/todomodels/todomodle.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todos');
  runApp(TodoApp());

  // runApp(ChangeNotifierProvider(
  //   create: (context) => AppLocaleProvider(),
  //   child: TodoApp(),
  // ));
}

class TodoApp extends StatefulWidget {

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_TodoAppState>();
    state!.setLocale(newLocale);
  }


  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {

  late Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
  @override
  void didChangeDependencies() async {

    Locale locale = await LocaleConstants.getLocale();
    setState(() {
      _locale = locale;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale?.languageCode == locale?.languageCode &&
              supportedLocale?.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales?.first;
      },
      locale: _locale,
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
        Locale('es', ''),
        Locale('ru', ''),
      ],
      // locale: Locale('en'), // Set the default locale
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final _todosBox = Hive.box<Todo>('todos');
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadDemoData();
  }

  Future<void> _loadDemoData() async {
    if (_todosBox.isEmpty) {
      _todosBox.add(Todo(title: 'Task 1', description: 'This is task 1'));
      _todosBox.add(Todo(title: 'Task 2', description: 'This is task 2'));
      _todosBox.add(Todo(title: 'Task 3', description: 'This is task 3'));
    } else {
      await _updateDemoData();
    }
  }

  Future<void> _updateDemoData() async {
    switch (_currentLanguage) {
      case 'es':
        _todosBox.putAt(0, Todo(title: 'Tarea 1', description: 'Esta es la tarea 1'));
        _todosBox.putAt(1, Todo(title: 'Tarea 2', description: 'Esta es la tarea 2'));
        _todosBox.putAt(2, Todo(title: 'Tarea 3', description: 'Esta es la tarea 3'));
        break;
      case 'ar':
        _todosBox.putAt(0, Todo(title: 'مهمة 1', description: 'هذه هي المهمة 1'));
        _todosBox.putAt(1, Todo(title: 'مهمة 2', description: 'هذه هي المهمة 2'));
        _todosBox.putAt(2, Todo(title: 'مهمة 3', description: 'هذه هي المهمة 3'));
        break;
      case 'ru':
        _todosBox.putAt(0, Todo(title: 'Задача 1', description: 'Это задача 1'));
        _todosBox.putAt(1, Todo(title: 'Задача 2', description: 'Это задача 2'));
        _todosBox.putAt(2, Todo(title: 'Задача 3', description: 'Это задача 3'));
        break;
      default:
        _todosBox.putAt(0, Todo(title: 'Task 1', description: 'This is task 1'));
        _todosBox.putAt(1, Todo(title: 'Task 2', description: 'This is task 2'));
        _todosBox.putAt(2, Todo(title: 'Task 3', description: 'This is task 3'));
    }
  }


  @override
  Widget build(BuildContext context) {

    // final localeProvider = Provider.of<AppLocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('app_title')),
        actions: [
          DropdownButton<String>(
            value: _currentLanguage,
            items: const [
              DropdownMenuItem(
                value: 'en',
                child: Text('English'),
              ),
              DropdownMenuItem(
                value: 'es',
                child: Text('Spanish'),
              ),
              DropdownMenuItem(
                value: 'ar',
                child: Text('Arabic'),
              ),
              DropdownMenuItem(
                value: 'ru',
                child: Text('Russian'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _currentLanguage = value!;

                // localeProvider.setLocale(value!);
                LocaleConstants.changeLanguage(context, _currentLanguage);
                _updateDemoData(); // Update demo data when language changes


              });
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Todo>>(
        valueListenable: _todosBox.listenable(),
        builder: (context, box, child) {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final todo = box.getAt(index);
              return ListTile(
                title: Text(todo!.title),
                subtitle: Text(todo.description),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context).translate('add_todo')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).translate('title'),
                      ),
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).translate('description'),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context).translate('cancel')),
                  ),
                  TextButton(
                    onPressed: () {
                      _todosBox.add(Todo(
                        title: _titleController.text,
                        description: _descriptionController.text,
                      ));
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context).translate('add')),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}




