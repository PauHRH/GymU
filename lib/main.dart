import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const GymUApp());
}

class GymUApp extends StatefulWidget {
  const GymUApp({super.key});
  @override
  State<GymUApp> createState() => _GymUAppState();
}

class _GymUAppState extends State<GymUApp> {
  ThemeMode _themeMode = ThemeMode.system;
  String? _profileImagePath;
  String? _userName;

  void setThemeMode(ThemeMode? mode) {
    setState(() => _themeMode = mode ?? ThemeMode.system);
  }

  void setProfileImage(String? path) {
    setState(() => _profileImagePath = path);
  }

  void setUserName(String? name) {
    setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymU',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFD32F2F),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFFD32F2F),
          secondary: Colors.black,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD32F2F)),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD32F2F),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFD32F2F),
          secondary: Colors.white,
          surface: Colors.black,
          onPrimary: Colors.white,
          onSecondary: const Color(0xFFD32F2F),
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD32F2F)),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.grey[900],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: _themeMode,
      home: AuthScreen(
        onLogin: (String email, String? name, String? imagePath) {
          setUserName(name);
          setProfileImage(imagePath);
        },
        builder: (context, userEmail) => MainScreen(
          userEmail: userEmail,
          profileImagePath: _profileImagePath,
          userName: _userName,
          onThemeChange: setThemeMode,
          onProfileImageChange: setProfileImage,
        ),
      ),
    );
  }
}

// --- Pantalla de autenticación ---
class AuthScreen extends StatefulWidget {
  final void Function(String email, String? name, String? imagePath)? onLogin;
  final Widget Function(BuildContext, String userEmail)? builder;
  const AuthScreen({super.key, this.onLogin, this.builder});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLogin = true;
  String? _userEmail;
  String? _userName;
  String? _profileImagePath;

  void _onLogin(String email, {String? name, String? imagePath}) {
    setState(() {
      _userEmail = email;
      _userName = name;
      _profileImagePath = imagePath;
    });
    if (widget.onLogin != null) {
      widget.onLogin!(email, name, imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userEmail != null && widget.builder != null) {
      return widget.builder!(context, _userEmail!);
    }
    return showLogin
        ? LoginPage(onRegisterTap: () => setState(() => showLogin = false), onLogin: _onLogin)
        : RegisterPage(onLoginTap: () => setState(() => showLogin = true));
  }
}

// --- Login ---
class LoginPage extends StatefulWidget {
  final VoidCallback onRegisterTap;
  final void Function(String email, {String? name, String? imagePath})? onLogin;
  const LoginPage({super.key, required this.onRegisterTap, this.onLogin});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String error = '';
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);
    final response = await http.post(
      Uri.parse('http://localhost:3000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );
    setState(() => loading = false);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      widget.onLogin?.call(emailController.text, name: data['name'], imagePath: data['profileImage']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(userEmail: emailController.text, profileImagePath: data['profileImage'], userName: data['name']),
        ),
      );
    } else {
      setState(() {
        error = jsonDecode(response.body)['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(32),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 72,
                    color: Color(0xFFD32F2F),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Bienvenido a GymU',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800])),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar'),
                  ),
                ),
                TextButton(
                  onPressed: widget.onRegisterTap,
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(error, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Registro ---
class RegisterPage extends StatefulWidget {
  final VoidCallback onLoginTap;
  const RegisterPage({super.key, required this.onLoginTap});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String error = '';
  String success = '';
  bool loading = false;

  Future<void> register() async {
    setState(() => loading = true);
    final response = await http.post(
      Uri.parse('http://localhost:3000/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );
    setState(() => loading = false);
    if (response.statusCode == 200) {
      setState(() {
        success = 'Registro exitoso. Ahora puedes iniciar sesión.';
        error = '';
      });
    } else {
      setState(() {
        error = jsonDecode(response.body)['message'];
        success = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(32),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 72,
                    color: Color(0xFFD32F2F),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Crea tu cuenta',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800])),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : register,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Registrarse'),
                  ),
                ),
                TextButton(
                  onPressed: widget.onLoginTap,
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(error, style: const TextStyle(color: Colors.red)),
                  ),
                if (success.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(success, style: const TextStyle(color: Colors.green)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- MainScreen con Bottom Navigation ---
class MainScreen extends StatefulWidget {
  final String userEmail;
  final String? profileImagePath;
  final String? userName;
  final ValueChanged<ThemeMode?>? onThemeChange;
  final void Function(String?)? onProfileImageChange;
  const MainScreen({super.key, required this.userEmail, this.profileImagePath, this.userName, this.onThemeChange, this.onProfileImageChange});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        userEmail: widget.userEmail,
        userName: widget.userName,
        profileImagePath: widget.profileImagePath,
        onProfileTap: _showProfileMenu,
        onSectionTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      RoutinePage(userEmail: widget.userEmail),
      ProgressPage(userEmail: widget.userEmail),
      ProfileSettingsPage(
        userEmail: widget.userEmail,
        userName: widget.userName,
        profileImagePath: widget.profileImagePath,
        onThemeChange: widget.onThemeChange,
        onProfileImageChange: widget.onProfileImageChange,
      ),
    ];
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: widget.profileImagePath != null ? AssetImage(widget.profileImagePath!) : null,
              child: widget.profileImagePath == null ? const Icon(Icons.person, size: 36) : null,
            ),
            const SizedBox(height: 12),
            Text(widget.userName ?? widget.userEmail, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes de usuario'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 3);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Rutinas'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progreso'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// --- HomePage con AppBar profesional ---
class HomePage extends StatelessWidget {
  final String userEmail;
  final String? userName;
  final String? profileImagePath;
  final VoidCallback? onProfileTap;
  final void Function(int)? onSectionTap;
  const HomePage({super.key, required this.userEmail, this.userName, this.profileImagePath, this.onProfileTap, this.onSectionTap});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                Text('¡Hola!', style: TextStyle(fontSize: 24, color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text(userName ?? userEmail, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center, color: Color(0xFFD32F2F), size: 40),
                    title: const Text('Tus rutinas', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Crea y gestiona tus ejercicios'),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      if (onSectionTap != null) onSectionTap!(1);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.show_chart, color: Color(0xFFD32F2F), size: 40),
                    title: const Text('Progreso', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Visualiza tu evolución'),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      if (onSectionTap != null) onSectionTap!(2);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: GestureDetector(
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withOpacity(0.7),
                    backgroundImage: profileImagePath != null ? AssetImage(profileImagePath!) : null,
                    child: profileImagePath == null ? const Icon(Icons.person, color: Color(0xFFD32F2F)) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Página de Progreso real ---
class ProgressPage extends StatefulWidget {
  final String userEmail;
  const ProgressPage({super.key, required this.userEmail});
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<Map<String, dynamic>> allExercises = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAllExercises();
  }

  Future<void> fetchAllExercises() async {
    // Obtiene todas las rutinas del usuario
    final routinesRes = await http.get(Uri.parse('http://localhost:3000/routines/${widget.userEmail}'));
    if (routinesRes.statusCode != 200) return;
    final routines = jsonDecode(routinesRes.body) as List;
    List<Map<String, dynamic>> exercises = [];
    for (final routine in routines) {
      final exRes = await http.get(Uri.parse('http://localhost:3000/routine/${routine['id']}/exercises'));
      if (exRes.statusCode == 200) {
        final exList = jsonDecode(exRes.body) as List;
        for (final ex in exList) {
          exercises.add({
            'id': ex['id'],
            'name': ex['name'],
            'routine': routine['name'],
          });
        }
      }
    }
    setState(() {
      allExercises = exercises;
      loading = false;
    });
  }

  Future<double> fetchMaxWeight(int exerciseId) async {
    final res = await http.get(Uri.parse('http://localhost:3000/exercise/history/$exerciseId'));
    if (res.statusCode != 200) return 0;
    final history = jsonDecode(res.body) as List;
    if (history.isEmpty) return 0;
    return history.map((e) => (e['weight'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progreso general')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : allExercises.isEmpty
              ? const Center(child: Text('No hay ejercicios registrados.'))
              : ListView.builder(
                  itemCount: allExercises.length,
                  itemBuilder: (context, index) {
                    final ex = allExercises[index];
                    return FutureBuilder<double>(
                      future: fetchMaxWeight(ex['id']),
                      builder: (context, snapshot) {
                        final maxWeight = snapshot.data ?? 0;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.fitness_center, color: Color(0xFFD32F2F)),
                            title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Rutina: ${ex['routine']}'),
                            trailing: Text('${maxWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

// --- ProfilePage con ajustes de usuario ---
class ProfileSettingsPage extends StatelessWidget {
  final String? userEmail;
  final String? userName;
  final String? profileImagePath;
  final ValueChanged<ThemeMode?>? onThemeChange;
  final void Function(String?)? onProfileImageChange;
  const ProfileSettingsPage({super.key, this.userEmail, this.userName, this.profileImagePath, this.onThemeChange, this.onProfileImageChange});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && onProfileImageChange != null) {
      onProfileImageChange!(picked.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen de perfil actualizada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 48,
              backgroundImage: profileImagePath != null ? FileImage(File(profileImagePath!)) : null,
              child: profileImagePath == null ? const Icon(Icons.person, size: 48) : null,
            ),
            const SizedBox(height: 16),
            Text(userName ?? userEmail ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 8),
            Text(userEmail ?? '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Tema'),
              trailing: DropdownButton<ThemeMode>(
                value: Theme.of(context).brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('Automático')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Oscuro')),
                ],
                onChanged: onThemeChange,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Cambiar imagen de perfil'),
              onTap: () => _pickImage(context),
            ),
            // ...otros ajustes...
          ],
        ),
      ),
    );
  }
}

// --- Pantalla de Rutinas (gestión de rutinas y ejercicios por rutina) ---
class RoutinePage extends StatefulWidget {
  final String userEmail;
  const RoutinePage({super.key, required this.userEmail});
  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final TextEditingController routineController = TextEditingController();
  List<Map<String, dynamic>> routines = [];

  @override
  void initState() {
    super.initState();
    fetchRoutines();
  }

  Future<void> fetchRoutines() async {
    final response = await http.get(Uri.parse('http://localhost:3000/routines/${widget.userEmail}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        routines = data.map((e) => {
          'id': e['id'],
          'name': e['name'],
        }).toList();
      });
    }
  }

  Future<void> addRoutine() async {
    final name = routineController.text.trim();
    if (name.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/routine'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.userEmail,
          'name': name,
        }),
      );
      if (response.statusCode == 200) {
        routineController.clear();
        fetchRoutines();
      }
    }
  }

  void goToRoutineDetail(Map<String, dynamic> routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineDetailPage(
          routineId: routine['id'],
          routineName: routine['name'],
          userEmail: widget.userEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Rutinas')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD32F2F),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: routineController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la rutina',
                      prefixIcon: Icon(Icons.list_alt),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        addRoutine();
                      },
                      child: const Text('Agregar rutina'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: routines.isEmpty
            ? const Center(child: Text('No tienes rutinas aún.'))
            : ListView.builder(
                itemCount: routines.length,
                itemBuilder: (context, index) {
                  final routine = routines[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.list_alt, size: 48, color: Color(0xFFD32F2F)),
                      title: GestureDetector(
                        onTap: () => goToRoutineDetail(routine),
                        child: Text(
                          routine['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.underline),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// --- Detalle de Rutina: ejercicios de la rutina ---
class RoutineDetailPage extends StatefulWidget {
  final int routineId;
  final String routineName;
  final String userEmail;
  const RoutineDetailPage({super.key, required this.routineId, required this.routineName, required this.userEmail});
  @override
  State<RoutineDetailPage> createState() => _RoutineDetailPageState();
}

class _RoutineDetailPageState extends State<RoutineDetailPage> {
  final TextEditingController exerciseController = TextEditingController();
  List<Map<String, dynamic>> exercises = [];
  Map<String, String> exerciseImages = {
    'Press Banca': 'assets/press_banca.png',
    'Sentadilla': 'assets/sentadilla.png',
    'Peso Muerto': 'assets/peso_muerto.png',
    'Dominadas': 'assets/dominadas.png',
    'Curl Bíceps': 'assets/curl_biceps.png',
    'Press Militar': 'assets/press_militar.png',
    'Remo': 'assets/remo.png',
    // ...agrega más ejercicios e imágenes aquí...
  };
  List<String> popularExercises = [
    'Press Banca',
    'Sentadilla',
    'Peso Muerto',
    'Dominadas',
    'Curl Bíceps',
    'Press Militar',
    'Remo',
  ];

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    final response = await http.get(Uri.parse('http://localhost:3000/routine/${widget.routineId}/exercises'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        exercises = data.map((e) => {
          'id': e['id'],
          'name': e['name'],
          'maxWeight': e['max_weight'],
        }).toList();
      });
    }
  }

  Future<void> addExercise(String name) async {
    if (name.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/routine/${widget.routineId}/exercise'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'maxWeight': 0, // Siempre enviar 0
        }),
      );
      if (response.statusCode == 200) {
        fetchExercises();
      }
    }
  }

  void showAddExerciseSheet() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        child: Container(
          width: 380,
          constraints: const BoxConstraints(maxHeight: 480),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selecciona un ejercicio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    ...popularExercises.map((exName) => GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        addExercise(exName);
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              exerciseImages[exName] ?? 'assets/default.png',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(exName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    )),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Ejercicio personalizado'),
                            content: TextField(
                              controller: exerciseController,
                              decoration: const InputDecoration(labelText: 'Nombre del ejercicio'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final name = exerciseController.text.trim();
                                  if (name.isNotEmpty) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    addExercise(name);
                                    exerciseController.clear();
                                  }
                                },
                                child: const Text('Agregar'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.add, size: 56, color: Color(0xFFD32F2F)),
                          ),
                          const SizedBox(height: 4),
                          const Text('Personalizado', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFFD32F2F))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void goToExerciseDetail(Map<String, dynamic> exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailPage(
          exerciseId: exercise['id'],
          exerciseName: exercise['name'],
          imagePath: exerciseImages[exercise['name']],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.routineName)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD32F2F),
        onPressed: showAddExerciseSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: exercises.isEmpty
            ? const Center(child: Text('No tienes ejercicios en esta rutina.'))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  final imagePath = exerciseImages[ex['name']];
                  return GestureDetector(
                    onTap: () => goToExerciseDetail(ex),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (imagePath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(imagePath, width: 70, height: 70, fit: BoxFit.cover),
                            )
                          else
                            const Icon(Icons.fitness_center, size: 60, color: Color(0xFFD32F2F)),
                          const SizedBox(height: 10),
                          Text(
                            ex['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// --- Pantalla de Detalle de Ejercicio (con gráfica) ---
class ExerciseDetailPage extends StatefulWidget {
  final int exerciseId;
  final String exerciseName;
  final String? imagePath;
  const ExerciseDetailPage({super.key, required this.exerciseId, required this.exerciseName, this.imagePath});
  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  final TextEditingController weightController = TextEditingController();
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final response = await http.get(Uri.parse('http://localhost:3000/exercise/history/${widget.exerciseId}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        history = data.map((e) => {
          'date': e['date'],
          'weight': e['weight'],
        }).toList();
      });
    }
  }

  Future<void> addWeight() async {
    final weight = double.tryParse(weightController.text.trim());
    if (weight != null) {
      final response = await http.post(
        Uri.parse('http://localhost:3000/exercise/history'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'exerciseId': widget.exerciseId,
          'date': DateTime.now().toIso8601String().substring(0, 10),
          'weight': weight,
        }),
      );
      if (response.statusCode == 200) {
        weightController.clear();
        fetchHistory();
      }
    }
  }

  String formatDate(String date) {
    // Espera formato yyyy-MM-dd
    final parts = date.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}'; // dd/MM
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exerciseName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(widget.imagePath!, width: 140, height: 140, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Nuevo peso máximo (kg)',
                prefixIcon: Icon(Icons.fitness_center_outlined),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addWeight,
                child: const Text('Actualizar peso'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Historial de pesos:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: history.isEmpty
                  ? const Center(child: Text('Sin datos'))
                  : Card(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey.shade400, width: 1),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (int i = 0; i < history.length; i++)
                                    FlSpot(i.toDouble(), history[i]['weight'].toDouble()),
                                ],
                                isCurved: true,
                                color: const Color(0xFFD32F2F),
                                barWidth: 4,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                    radius: 5,
                                    color: Colors.white,
                                    strokeWidth: 3,
                                    strokeColor: const Color(0xFFD32F2F),
                                  ),
                                ),
                                belowBarData: BarAreaData(show: true, color: const Color(0x33D32F2F)),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: (history.length > 1) ? ((history.length - 1) / 3).clamp(1, 100).toDouble() : 1,
                                  getTitlesWidget: (value, meta) {
                                    int idx = value.toInt();
                                    if (idx >= 0 && idx < history.length) {
                                      // Solo muestra 3-5 fechas máximo
                                      if (history.length <= 5 || idx == 0 || idx == history.length - 1 || idx == (history.length ~/ 2)) {
                                        return Text(formatDate(history[idx]['date']), style: const TextStyle(fontSize: 12));
                                      }
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
