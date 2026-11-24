import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/auth/view/login_page.dart';
import 'features/clientes/data/clientes_service.dart';
import 'features/clientes/data/clientes_repository.dart';
import 'features/clientes/view_model/clientes_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // O Provider fica no topo do app, disponível para todas as telas
        ChangeNotifierProvider(
          create: (_) => ClientesViewModel(ClientesRepository(ClientesService())),
        ),
      ],
      child: MaterialApp(
        title: 'Top Açaí RV',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}