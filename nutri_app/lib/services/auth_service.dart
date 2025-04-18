import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _storage = FlutterSecureStorage();
  static const _keyEmail = 'aYWpsCE3hD)zb2!A';
  static const _keySenha = 'bEW[Pn+vr8743y>F';

  // Método para fazer login
  Future<Map<String, dynamic>?> login(String email, String senha) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      DocumentSnapshot userDoc =
          await _db.collection("usuarios").doc(userCredential.user!.uid).get();

      if (!userDoc.exists) return null;

      await salvarCredenciais(email, senha);

      return userDoc.data() as Map<String, dynamic>;
    } catch (e) {
      print("Erro ao fazer login: $e");
      return null;
    }
  }

  // Método para criar usuário (somente Coordenador pode criar)
  Future<bool> criarUsuario(
      String email, String senha, String nome, String tipoUsuario) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      String uid = userCredential.user!.uid;

      await _db.collection("usuarios").doc(uid).set({
        "id": uid,
        "nome": nome,
        "email": email,
        "tipo_usuario": tipoUsuario,
        "ativo": true
      });

      return true;
    } catch (e) {
      print("Erro ao criar usuário: $e");
      return false;
    }
  }

  // Método para logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> salvarCredenciais(String email, String senha) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keySenha, value: senha);
  }

  Future<Map<String, String>?> recuperarCredenciais() async {
    final email = await _storage.read(key: _keyEmail);
    final senha = await _storage.read(key: _keySenha);

    if (email != null && senha != null) {
      return {'email': email, 'senha': senha};
    }
    return null;
  }

  Future<void> limparCredenciais() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keySenha);
  }
}
