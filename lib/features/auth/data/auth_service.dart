import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fazer login
  Future<User?> login(String email, String senha) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Criar conta
  Future<User?> cadastrar(String email, String senha) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Deslogar
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Pegar usuário atual (se estiver logado)
  User? get usuarioAtual => _auth.currentUser;
}