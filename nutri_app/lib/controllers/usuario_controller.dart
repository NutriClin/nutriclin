import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class UsuarioController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> buscarUsuario(String id) async {
    try {
      var doc = await _firestore.collection('usuarios').doc(id).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print('Erro ao buscar usuário: $e');
    }
    return null;
  }

String _gerarSenhaTemporaria() {
  const String caracteres =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_=+';
  Random random = Random();
  return List.generate(12, (index) => caracteres[random.nextInt(caracteres.length)]).join();
}

Future<String> salvarUsuario({
  required String? idUsuario,
  required String nome,
  required String email,
  required String tipoUsuario,
  required bool ativo,
}) async {
  try {
    User? usuarioAtual = _auth.currentUser;
    if (usuarioAtual == null) {
      return 'Erro: Usuário não autenticado!';
    }

    DocumentSnapshot userDoc =
        await _firestore.collection('usuarios').doc(usuarioAtual.uid).get();
    String tipoAtual = userDoc['tipo_usuario'];

    if (tipoAtual != 'Coordenador') {
      return 'Apenas Coordenadores podem gerenciar usuários!';
    }

    if (idUsuario != null && idUsuario.isNotEmpty) {
      await _firestore.collection('usuarios').doc(idUsuario).update({
        'nome': nome,
        'email': email,
        'tipo_usuario': tipoUsuario,
        'ativo': ativo,
      });
      return 'Usuário atualizado com sucesso!';
    } else {
      String senhaTemporaria = _gerarSenhaTemporaria();

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senhaTemporaria,
      );

      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': nome,
        'email': email,
        'tipo_usuario': tipoUsuario,
        'ativo': true,
        'data': FieldValue.serverTimestamp(),
      });

      await _auth.sendPasswordResetEmail(email: email);

      return 'Usuário cadastrado! Um e-mail foi enviado para ele definir a senha.';
    }
  } catch (e) {
    return 'Erro ao salvar usuário: $e';
  }
}


  Future<String> atualizarSenha(String email, String novaSenha) async {
    try {
      User? usuarioAtual = _auth.currentUser;
      if (usuarioAtual == null) {
        return 'Erro: Usuário não autenticado!';
      }

      await usuarioAtual.updatePassword(novaSenha);

      return 'Senha atualizada com sucesso!';
    } catch (e) {
      return 'Erro ao atualizar senha: $e';
    }
  }

  Future<String> enviarRedefinicaoSenha(String idUsuario) async {
    try {
      User? usuarioAtual = _auth.currentUser;
      if (usuarioAtual == null) return 'Erro: Usuário não autenticado!';

      DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(usuarioAtual.uid).get();
      if (userDoc['tipo_usuario'] != 'Coordenador') {
        return 'Apenas Coordenadores podem solicitar redefinição!';
      }

      DocumentSnapshot usuarioAlvoDoc =
          await _firestore.collection('usuarios').doc(idUsuario).get();
      String emailUsuarioAlvo = usuarioAlvoDoc['email'];

      await _auth.sendPasswordResetEmail(email: emailUsuarioAlvo);
      return 'E-mail de redefinição enviado!';
    } catch (e) {
      return 'Erro: ${e.toString()}';
    }
  }

  Future<String> ativarDesativarUsuario({
    required String? idUsuario,
    required bool ativo,
  }) async {
    try {
      User? usuarioAtual = _auth.currentUser;
      if (usuarioAtual == null) {
        return 'Erro: Usuário não autenticado!';
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(usuarioAtual.uid).get();
      String tipoAtual = userDoc['tipo_usuario'];

      if (tipoAtual != 'Coordenador') {
        return 'Apenas Coordenadores podem gerenciar usuários!';
      }

      await _firestore.collection('usuarios').doc(idUsuario).update({
        'ativo': ativo,
      });
      return 'Usuário ${ativo ? "ativado" : "desativado"} com sucesso!';
    } catch (e) {
      return 'Erro ao salvar usuário: $e';
    }
  }
}
