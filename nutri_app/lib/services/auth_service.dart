import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para fazer login
  Future<Map<String, dynamic>?> login(String email, String senha) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Buscar dados do usuário no Firestore
      DocumentSnapshot userDoc = await _db.collection("usuarios").doc(userCredential.user!.uid).get();

      if (!userDoc.exists) return null;

      return userDoc.data() as Map<String, dynamic>;  // Retorna nome, tipo_usuario, etc.
    } catch (e) {
      print("Erro ao fazer login: $e");
      return null;
    }
  }

  // Método para criar usuário (somente Coordenador pode criar)
  Future<bool> criarUsuario(String email, String senha, String nome, String tipoUsuario) async {
    try {
      // Criar usuário no Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      String uid = userCredential.user!.uid;

      // Criar usuário no Firestore
      await _db.collection("usuarios").doc(uid).set({
        "id": uid,
        "nome": nome,
        "email": email,
        "tipo_usuario": tipoUsuario,  // "Aluno", "Professor" ou "Coordenador"
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

  
}
