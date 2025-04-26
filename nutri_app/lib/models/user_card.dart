import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserCard extends StatelessWidget {
  final String id;
  final String nome;
  final String email;
  final String tipoUsuario;
  final bool ativo;
  final DateTime dataHora;

  const UserCard({
    Key? key,
    required this.id,
    required this.nome,
    required this.email,
    required this.tipoUsuario,
    required this.ativo,
    required this.dataHora,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com nome e status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ativo ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ativo ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    ativo ? 'Ativo' : 'Inativo',
                    style: TextStyle(
                      color: ativo ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Email
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Tipo de usuário e data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tipo de usuário
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getColorForUserType(tipoUsuario),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tipoUsuario,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),

                // Data de cadastro
                Text(
                  DateFormat('dd/MM/yyyy').format(dataHora),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.blue,
                  onPressed: () {
                    // Ação de editar
                  },
                ),
                IconButton(
                  icon: Icon(ativo ? Icons.toggle_on : Icons.toggle_off),
                  color: ativo ? Colors.green : Colors.grey,
                  onPressed: () {
                    // Ação de alternar status
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForUserType(String type) {
    switch (type.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'professor':
        return Colors.blue;
      case 'nutricionista':
        return Colors.teal;
      case 'aluno':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}