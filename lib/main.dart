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
          themeMode: _themeMode,
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
  String? _profileImagePath;
  String? _userName;

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
      widget.onLogin?.call(emailController.text, name: data['username'], imagePath: data['profileImage']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(userEmail: emailController.text, profileImagePath: data['profileImage'], userName: data['username'], themeMode: ThemeMode.system),
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
  final TextEditingController nameController = TextEditingController();
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
        'username': nameController.text,
      }),
    );
    setState(() => loading = false);
    if (response.statusCode == 200) {
      // Registro exitoso, ahora login automático
      final loginResponse = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );
      if (loginResponse.statusCode == 200) {
        final data = jsonDecode(loginResponse.body);
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                userEmail: emailController.text,
                profileImagePath: data['profileImage'],
                userName: data['username'],
                themeMode: ThemeMode.system,
              ),
            ),
          );
        }
      } else {
        setState(() {
          error = 'Registro exitoso, pero error al iniciar sesión.';
          success = '';
        });
      }
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
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
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
  final ThemeMode themeMode;
  const MainScreen({super.key, required this.userEmail, this.profileImagePath, this.userName, this.onThemeChange, this.onProfileImageChange, required this.themeMode});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? userRole;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final res = await http.get(Uri.parse('http://localhost:3000/user/${widget.userEmail}'));
    print('Respuesta backend rol: ${res.body}');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print('Valor recibido de role: ${data['role']}');
      setState(() {
        userRole = data['role'] ?? 'user';
      });
    } else {
      print('Error al obtener el rol: ${res.statusCode}');
    }
  }

  void _showProfileMenu() async {
    await fetchUserRole(); // Espera a que el rol esté actualizado antes de mostrar el menú
    // Espera un frame para asegurar que setState termine
    if (!mounted) return;
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
            if (userRole == 'admin')
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                title: const Text('Panel de administración'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminPanel(userEmail: widget.userEmail),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => AuthScreen(
                    onLogin: (String email, String? name, String? imagePath) {},
                    builder: (context, userEmail) => MainScreen(
                      userEmail: userEmail,
                      profileImagePath: null,
                      userName: null,
                      onThemeChange: null,
                      onProfileImageChange: null,
                      themeMode: ThemeMode.system,
                    ),
                  )),
                  (route) => false,
                );
              },
            ),
            // Línea de depuración para mostrar el rol actual
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Rol: ${userRole ?? "cargando..."}', style: const TextStyle(fontSize: 14, color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
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
        userRole: userRole,
        themeMode: widget.themeMode,
      ),
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: pages[_selectedIndex],
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
                Text('¡Hola, $userName!', style: TextStyle(fontSize: 24, color: Colors.grey[700])),
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

// --- SLIDER DE RUTINA ASIGNADA EN HOME Y SELECCIÓN DE RUTINA PREDETERMINADA ---
class AssignedRoutineSlider extends StatefulWidget {
  final String userEmail;
  const AssignedRoutineSlider({super.key, required this.userEmail});
  @override
  State<AssignedRoutineSlider> createState() => _AssignedRoutineSliderState();
}

class _AssignedRoutineSliderState extends State<AssignedRoutineSlider> {
  Map? assignedRoutine;
  List defaultRoutines = [];
  List userRoutines = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAssignedRoutine();
    fetchDefaultRoutines();
    fetchUserRoutines();
  }

  Future<void> fetchAssignedRoutine() async {
    final res = await http.get(Uri.parse('http://localhost:3000/user/${widget.userEmail}/assigned-routine'));
    if (res.statusCode == 200) {
      setState(() {
        assignedRoutine = jsonDecode(res.body);
        loading = false;
      });
    }
  }

  Future<void> fetchDefaultRoutines() async {
    final res = await http.get(Uri.parse('http://localhost:3000/default-routines'));
    if (res.statusCode == 200) {
      setState(() {
        defaultRoutines = jsonDecode(res.body);
      });
    }
  }

  Future<void> fetchUserRoutines() async {
    final res = await http.get(Uri.parse('http://localhost:3000/routines/${widget.userEmail}'));
    if (res.statusCode == 200) {
      setState(() {
        userRoutines = jsonDecode(res.body);
      });
    }
  }

  Future<void> assignRoutine(int routineId, {bool isDefault = false}) async {
    if (isDefault) {
      await http.post(
        Uri.parse('http://localhost:3000/assign-default-routine'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_email': widget.userEmail,
          'routine_id': routineId,
        }),
      );
    } else {
      // Asignar rutina propia: puedes usar el mismo endpoint o uno específico si tienes
      await http.post(
        Uri.parse('http://localhost:3000/assign-user-routine'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_email': widget.userEmail,
          'routine_id': routineId,
        }),
      );
    }
    fetchAssignedRoutine();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rutina asignada')));
  }

  void showRoutineSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SizedBox(
        height: 500,
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text('Elige tu rutina activa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (defaultRoutines.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Rutinas predeterminadas', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...defaultRoutines.map<Widget>((r) => ListTile(
                          leading: r['image_url'] != null && r['image_url'].toString().isNotEmpty
                              ? Image.network('http://localhost:3000/${r['image_url']}', width: 48, height: 48, fit: BoxFit.cover)
                              : const Icon(Icons.star, color: Color(0xFFD32F2F)),
                          title: Text(r['name']),
                          trailing: assignedRoutine != null && assignedRoutine!['id'] == r['id'] ? const Icon(Icons.check, color: Colors.green) : null,
                          onTap: () {
                            Navigator.pop(context);
                            assignRoutine(r['id'], isDefault: true);
                          },
                        )),
                  ],
                  if (userRoutines.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Tus rutinas personalizadas', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...userRoutines.map<Widget>((r) => ListTile(
                          leading: const Icon(Icons.fitness_center, color: Color(0xFFD32F2F)),
                          title: Text(r['name']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (assignedRoutine != null && assignedRoutine!['id'] == r['id'])
                                const Icon(Icons.check, color: Colors.green),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                tooltip: 'Gestionar ejercicios',
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RoutineDetailPage(
                                        routineId: r['id'],
                                        routineName: r['name'],
                                        userEmail: widget.userEmail,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            assignRoutine(r['id'], isDefault: false);
                          },
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (assignedRoutine == null) {
      return Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Elegir rutina'),
          onPressed: showRoutineSelector,
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (assignedRoutine!['image_url'] != null && assignedRoutine!['image_url'].toString().isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network('http://localhost:3000/${assignedRoutine!['image_url']}', width: 220, height: 220, fit: BoxFit.cover),
          )
        else
          const Icon(Icons.fitness_center, size: 180, color: Color(0xFFD32F2F)),
        const SizedBox(height: 24),
        Text(
          assignedRoutine!['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Cambiar rutina'),
          onPressed: showRoutineSelector,
        ),
        if (userRoutines.any((r) => assignedRoutine!['id'] == r['id']))
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Gestionar ejercicios'),
              onPressed: () {
                final r = userRoutines.firstWhere((r) => assignedRoutine!['id'] == r['id']);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoutineDetailPage(
                      routineId: r['id'],
                      routineName: r['name'],
                      userEmail: widget.userEmail,
                    ),
                  ),
                );
              },
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
  final String? userRole;
  final ThemeMode themeMode;
  const ProfileSettingsPage({super.key, this.userEmail, this.userName, this.profileImagePath, this.onThemeChange, this.onProfileImageChange, this.userRole, required this.themeMode});

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
                value: themeMode,
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
            if (userRole == 'admin')
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                title: const Text('Panel de administración'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminPanel(userEmail: userEmail ?? ''),
                    ),
                  );
                },
              ),
            Text('Rol: ${userRole ?? "cargando..."}', style: const TextStyle(fontSize: 14, color: Colors.red)),
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
  List<Map<String, dynamic>> allExercises = [];
  int? selectedSets;
  int? selectedReps;

  @override
  void initState() {
    super.initState();
    fetchExercises();
    fetchAllExercisesFromDB();
  }

  Future<void> fetchExercises() async {
    final response = await http.get(Uri.parse('http://localhost:3000/routine/${widget.routineId}/exercises'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        exercises = data.map((e) => {
          'id': e['id'],
          'exercise_id': e['exercise_id'],
          'name': e['exercise_name'] ?? e['name'],
          'sets': e['sets'],
          'reps': e['reps'],
          'image_url': e['image_url'],
          'description': e['description'],
        }).toList();
      });
    }
  }

  Future<void> fetchAllExercisesFromDB() async {
    final response = await http.get(Uri.parse('http://localhost:3000/exercises'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        allExercises = data.map((e) => {
          'id': e['id'],
          'name': e['name'],
          'image_url': e['image_url'],
          'description': e['description'],
        }).toList();
      });
    }
  }

  Future<void> addExercise(int exerciseId, int sets, int reps) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/routine/${widget.routineId}/exercise'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'exercise_id': exerciseId,
        'sets': sets,
        'reps': reps,
      }),
    );
    if (response.statusCode == 200) {
      fetchExercises();
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
          constraints: const BoxConstraints(maxHeight: 520),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selecciona un ejercicio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    ...allExercises.map((ex) => GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            int sets = 3;
                            int reps = 10;
                            return AlertDialog(
                              title: Text('Agregar ${ex['name']}'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('¿Cuántos sets y repeticiones?'),
                                  Row(
                                    children: [
                                      const Text('Sets:'),
                                      const SizedBox(width: 8),
                                      DropdownButton<int>(
                                        value: sets,
                                        items: List.generate(10, (i) => i + 1).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                                        onChanged: (v) {
                                          if (v != null) sets = v;
                                        },
                                      ),
                                      const SizedBox(width: 16),
                                      const Text('Reps:'),
                                      const SizedBox(width: 8),
                                      DropdownButton<int>(
                                        value: reps,
                                        items: List.generate(30, (i) => i + 1).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                                        onChanged: (v) {
                                          if (v != null) reps = v;
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    addExercise(ex['id'], sets, reps);
                                  },
                                  child: const Text('Agregar'),
                                ),
                              ],
                            );
                          },
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
                            child: ex['image_url'] != null && ex['image_url'].toString().isNotEmpty
                              ? Image.network('http://localhost:3000/${ex['image_url']}', width: 56, height: 56, fit: BoxFit.cover)
                              : const Icon(Icons.fitness_center, size: 56, color: Color(0xFFD32F2F)),
                          ),
                          const SizedBox(height: 4),
                          Text(ex['name'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
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
                                    // Aquí podrías crear el ejercicio personalizado en la base de datos y luego agregarlo
                                    // Por simplicidad, solo lo agregamos con sets/reps por defecto
                                    // Deberías implementar la lógica para crear el ejercicio y luego obtener su id
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
          exerciseId: exercise['exercise_id'] ?? exercise['id'],
          exerciseName: exercise['name'],
          imagePath: exercise['image_url'],
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
                  return GestureDetector(
                    onTap: () => goToExerciseDetail(ex),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (ex['image_url'] != null && ex['image_url'].toString().isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network('http://localhost:3000/${ex['image_url']}', width: 70, height: 70, fit: BoxFit.cover),
                            )
                          else
                            const Icon(Icons.fitness_center, size: 60, color: Color(0xFFD32F2F)),
                          const SizedBox(height: 10),
                          Text(
                            ex['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          if (ex['sets'] != null && ex['reps'] != null)
                            Text('${ex['sets']} x ${ex['reps']}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(show: true, color: const Color(0x33D32F2F)),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
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

// --- Panel de Administración Completo ---
class AdminPanel extends StatefulWidget {
  final String userEmail;
  const AdminPanel({super.key, required this.userEmail});
  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  static const List<String> _titles = [
    'Usuarios',
    'Rutinas',
    'Rutinas Predeterminadas',
    'Ejercicios',
    'Asignar Rutina',
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminUsersPage(),
      AdminRoutinesPage(),
      AdminDefaultRoutinesPage(),
      AdminExercisesPage(userEmail: widget.userEmail),
      AdminAssignRoutinePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Panel de Administración - ${_titles[_selectedIndex]}')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuarios'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Rutinas'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Predet.'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Ejercicios'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Asignar'),
        ],
      ),
    );
  }
}

// --- Sección: Gestión de Usuarios ---
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}
class _AdminUsersPageState extends State<AdminUsersPage> {
  List users = [];
  bool loading = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String role = 'user';
  int? editingId;
  @override
  void initState() { super.initState(); fetchUsers(); }
  Future<void> fetchUsers() async {
    setState(() => loading = true);
    final res = await http.get(Uri.parse('http://localhost:3000/admin/users'));
    if (res.statusCode == 200) {
      setState(() { users = jsonDecode(res.body); loading = false; });
    }
  }
  Future<void> saveUser() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    if (editingId == null) {
      await http.post(Uri.parse('http://localhost:3000/admin/users'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'username': username, 'password': password, 'role': role,}),);
    } else {
      await http.put(Uri.parse('http://localhost:3000/admin/users/$editingId'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username, 'role': role,}),);
    }
    emailController.clear(); usernameController.clear(); passwordController.clear(); editingId = null; fetchUsers();
  }
  Future<void> deleteUser(int id) async { await http.delete(Uri.parse('http://localhost:3000/admin/users/$id')); fetchUsers(); }
  void showEdit(Map user) { setState(() { editingId = user['id']; emailController.text = user['email']; usernameController.text = user['username']; role = user['role']; }); }
  @override
  Widget build(BuildContext context) {
    return loading ? const Center(child: CircularProgressIndicator()) : ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final user in users)
          Card(
            child: ListTile(
              leading: user['profile_image'] != null ? Image.network('http://localhost:3000/${user['profile_image']}', width: 40, height: 40, fit: BoxFit.cover) : const Icon(Icons.person, size: 32),
              title: Text(user['username'] ?? ''),
              subtitle: Text('${user['email']}\nRol: ${user['role']}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => showEdit(user)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteUser(user['id'])),
                ],
              ),
            ),
          ),
        const Divider(),
        Text(editingId == null ? 'Nuevo usuario' : 'Editar usuario', style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
        TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Nombre de usuario')),
        if (editingId == null) TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
        DropdownButton<String>(value: role, items: const [DropdownMenuItem(value: 'user', child: Text('Usuario')), DropdownMenuItem(value: 'admin', child: Text('Admin'))], onChanged: (v) => setState(() => role = v ?? 'user'),),
        ElevatedButton(onPressed: saveUser, child: Text(editingId == null ? 'Crear' : 'Actualizar')),
        if (editingId != null) TextButton(onPressed: () { setState(() { editingId = null; emailController.clear(); usernameController.clear(); passwordController.clear(); role = 'user'; }); }, child: const Text('Cancelar')),
      ],
    );
  }
}

// --- Sección: Gestión de Rutinas (solo visualización de predeterminadas) ---
class AdminRoutinesPage extends StatefulWidget {
  const AdminRoutinesPage({super.key});

  @override
  State<AdminRoutinesPage> createState() => _AdminRoutinesPageState();
}
class _AdminRoutinesPageState extends State<AdminRoutinesPage> {
  List routines = [];
  bool loading = true;
  @override
  void initState() { super.initState(); fetchRoutines(); }
  Future<void> fetchRoutines() async {
    setState(() => loading = true);
    final res = await http.get(Uri.parse('http://localhost:3000/admin/default-routines'));
    if (res.statusCode == 200) {
      setState(() { routines = jsonDecode(res.body); loading = false; });
    }
  }
  @override
  Widget build(BuildContext context) {
    return loading ? const Center(child: CircularProgressIndicator()) : ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final routine in routines)
          Card(
            child: ListTile(
              leading: routine['image_url'] != null && routine['image_url'].toString().isNotEmpty ? Image.network('http://localhost:3000/${routine['image_url']}', width: 48, height: 48, fit: BoxFit.cover) : const Icon(Icons.star, color: Color(0xFFD32F2F)),
              title: Text(routine['name']),
              subtitle: const Text('Rutina predeterminada'),
            ),
          ),
      ],
    );
  }
}

// --- Sección: Gestión de Rutinas Predeterminadas (CRUD) ---
class AdminDefaultRoutinesPage extends StatefulWidget {
  const AdminDefaultRoutinesPage({super.key});

  @override
  State<AdminDefaultRoutinesPage> createState() => _AdminDefaultRoutinesPageState();
}
class _AdminDefaultRoutinesPageState extends State<AdminDefaultRoutinesPage> {
  List routines = [];
  bool loading = true;
  final TextEditingController nameController = TextEditingController();
  List exercises = [];
  List selectedExercises = [];
  @override
  void initState() { super.initState(); fetchRoutines(); fetchExercises(); }
  Future<void> fetchRoutines() async {
    setState(() => loading = true);
    final res = await http.get(Uri.parse('http://localhost:3000/admin/default-routines'));
    if (res.statusCode == 200) {
      setState(() { routines = jsonDecode(res.body); loading = false; });
    }
  }
  Future<void> fetchExercises() async {
    final res = await http.get(Uri.parse('http://localhost:3000/exercises'));
    if (res.statusCode == 200) {
      setState(() { exercises = jsonDecode(res.body); });
    }
  }
  Future<void> saveRoutine() async {
    final name = nameController.text.trim();
    if (name.isEmpty || selectedExercises.isEmpty) return;
    await http.post(Uri.parse('http://localhost:3000/admin/default-routine'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'name': name, 'exercises': selectedExercises}),);
    nameController.clear(); selectedExercises = []; fetchRoutines();
  }
  @override
  Widget build(BuildContext context) {
    return loading ? const Center(child: CircularProgressIndicator()) : ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final routine in routines)
          Card(
            child: ListTile(
              title: Text(routine['name']),
              subtitle: const Text('Rutina predeterminada'),
            ),
          ),
        const Divider(),
        const Text('Nueva rutina predeterminada', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
        const SizedBox(height: 8),
        const Text('Selecciona ejercicios:'),
        Wrap(
          children: [
            for (final ex in exercises)
              FilterChip(
                label: Text(ex['name']),
                selected: selectedExercises.any((e) => e['exercise_id'] == ex['id']),
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      selectedExercises.add({'exercise_id': ex['id'], 'sets': 3, 'reps': 10});
                    } else {
                      selectedExercises.removeWhere((e) => e['exercise_id'] == ex['id']);
                    }
                  });
                },
              ),
          ],
        ),
        ElevatedButton(onPressed: saveRoutine, child: const Text('Crear rutina predeterminada')),
      ],
    );
  }
}

// --- Sección: Asignar Rutinas Predeterminadas ---
class AdminAssignRoutinePage extends StatefulWidget {
  const AdminAssignRoutinePage({super.key});

  @override
  State<AdminAssignRoutinePage> createState() => _AdminAssignRoutinePageState();
}
class _AdminAssignRoutinePageState extends State<AdminAssignRoutinePage> {
  List users = [];
  List routines = [];
  bool loading = true;
  int? selectedUserId;
  int? selectedRoutineId;
  @override
  void initState() { super.initState(); fetchData(); }
  Future<void> fetchData() async {
    setState(() => loading = true);
    final usersRes = await http.get(Uri.parse('http://localhost:3000/admin/users'));
    final routinesRes = await http.get(Uri.parse('http://localhost:3000/admin/default-routines'));
    if (usersRes.statusCode == 200 && routinesRes.statusCode == 200) {
      setState(() {
        users = jsonDecode(usersRes.body);
        routines = jsonDecode(routinesRes.body);
        loading = false;
      });
    }
  }
  Future<void> assignRoutine() async {
    if (selectedUserId == null || selectedRoutineId == null) return;
    final user = users.firstWhere((u) => u['id'] == selectedUserId);
    await http.post(Uri.parse('http://localhost:3000/admin/assign-default-routine'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'user_email': user['email'], 'routine_id': selectedRoutineId}),);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rutina asignada')));
  }
  @override
  Widget build(BuildContext context) {
    return loading ? const Center(child: CircularProgressIndicator()) : Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selecciona usuario:'),
          DropdownButton<int>(
            value: selectedUserId,
            items: users.map<DropdownMenuItem<int>>((u) => DropdownMenuItem(value: u['id'], child: Text(u['username'] ?? u['email']))).toList(),
            onChanged: (v) => setState(() => selectedUserId = v),
          ),
          const SizedBox(height: 16),
          const Text('Selecciona rutina predeterminada:'),
          DropdownButton<int>(
            value: selectedRoutineId,
            items: routines.map<DropdownMenuItem<int>>((r) => DropdownMenuItem(value: r['id'], child: Text(r['name']))).toList(),
            onChanged: (v) => setState(() => selectedRoutineId = v),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: assignRoutine, child: const Text('Asignar rutina')),
        ],
      ),
    );
  }
}

// --- Pantalla de gestión de ejercicios para admin ---
class AdminExercisePanel extends StatefulWidget {
  final String userEmail;
  const AdminExercisePanel({super.key, required this.userEmail});
  @override
  State<AdminExercisePanel> createState() => _AdminExercisePanelState();
}

class _AdminExercisePanelState extends State<AdminExercisePanel> {
  List<Map<String, dynamic>> exercises = [];
  bool loading = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  int? editingId;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    setState(() => loading = true);
    final res = await http.get(Uri.parse('http://localhost:3000/exercises'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      setState(() {
        exercises = data.map((e) => {
          'id': e['id'],
          'name': e['name'],
          'image_url': e['image_url'],
          'description': e['description'],
        }).toList();
        loading = false;
      });
    }
  }

  Future<void> saveExercise() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    if (name.isEmpty) return;
    if (editingId == null) {
      // Crear
      await http.post(
        Uri.parse('http://localhost:3000/exercises'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': desc,
          'image_url': null,
          'email': widget.userEmail,
        }),
      );
    } else {
      // Editar
      await http.put(
        Uri.parse('http://localhost:3000/exercises/$editingId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': desc,
          'image_url': null,
          'email': widget.userEmail,
        }),
      );
    }
    nameController.clear();
    descController.clear();
    editingId = null;
    fetchExercises();
  }

  Future<void> deleteExercise(int id) async {
    await http.delete(
      Uri.parse('http://localhost:3000/exercises/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.userEmail}),
    );
    fetchExercises();
  }

  Future<void> pickAndUploadImage(int id) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final req = http.MultipartRequest('POST', Uri.parse('http://localhost:3000/exercises/$id/image'));
      req.files.add(await http.MultipartFile.fromPath('image', picked.path));
      req.fields['email'] = widget.userEmail;
      await req.send();
      fetchExercises();
    }
  }

  void showEdit(Map<String, dynamic> ex) {
    setState(() {
      editingId = ex['id'];
      nameController.text = ex['name'];
      descController.text = ex['description'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Ejercicios (Admin)')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final ex in exercises)
                  Card(
                    child: ListTile(
                      leading: ex['image_url'] != null
                          ? Image.network('http://localhost:3000/${ex['image_url']}', width: 48, height: 48, fit: BoxFit.cover)
                          : const Icon(Icons.fitness_center, size: 40),
                      title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(ex['description'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => showEdit(ex)),
                          IconButton(icon: const Icon(Icons.image), onPressed: () => pickAndUploadImage(ex['id'])),
                          IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteExercise(ex['id'])),
                        ],
                      ),
                    ),
                  ),
                const Divider(),
                Text(editingId == null ? 'Nuevo ejercicio' : 'Editar ejercicio', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descripción')),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: saveExercise,
                  child: Text(editingId == null ? 'Crear' : 'Actualizar'),
                ),
                if (editingId != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        editingId = null;
                        nameController.clear();
                        descController.clear();
                      });
                    },
                    child: const Text('Cancelar'),
                  ),
              ],
            ),
    );
  }
}

// --- Sección: Gestión de Ejercicios (reutiliza tu panel actual) ---
class AdminExercisesPage extends StatelessWidget {
  final String userEmail;
  const AdminExercisesPage({super.key, required this.userEmail});
  @override
  Widget build(BuildContext context) {
    return AdminExercisePanel(userEmail: userEmail);
  }
}
