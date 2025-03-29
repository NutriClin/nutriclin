import 'package:flutter/material.dart';
import 'package:nutri_app/pages/usuario_detalhe.dart';

class CustomListUsuario extends StatelessWidget {
  final Map<String, dynamic> report;

  const CustomListUsuario({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  report["nome"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Text(
            "${report["data"].day}/${report["data"].month}/${report["data"].year} às ${report["data"].hour}:${report["data"].minute.toString().padLeft(2, '0')} Hrs",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                report["tipo_usuario"],
                style: TextStyle(
                  color: report["ativo"] == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 20),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UsuarioDetalhe(
                    idUsuario: report["id"]), // <-- Alterado aqui
              ),
            );
          },
        ),
        const Divider(),
      ],
    );
  }
}
