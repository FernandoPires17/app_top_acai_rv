import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import '../../clientes/view/clientes_page.dart'; // Import necessário para a próxima tela

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _erro;

  Future<void> _entrar() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      await _authService.login(
        _emailController.text.trim(),
        _senhaController.text.trim(),
      );

      // Se o login der certo, navega para a tela de Clientes
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ClientesPage()),
        );
      }
    } catch (e) {
      setState(() {
        _erro = 'Erro ao logar: verifique e-mail e senha.';
      });
    } finally {
      // ESSENCIAL: Garante que o botão volte ao normal se der erro
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  } // <--- AQUI ESTAVA FALTANDO FECHAR O MÉTODO _entrar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person, size: 80, color: Colors.purple.shade700),
              const SizedBox(height: 20),
              Text(
                'Top Açaí RV',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_erro != null)
                Text(_erro!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _entrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Entrar', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}