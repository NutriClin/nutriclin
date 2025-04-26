import 'package:flutter/material.dart';

class CustomListAtendimento extends StatelessWidget {
  final Map<String, dynamic> report;

  const CustomListAtendimento({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (report["status_atendimento"]) {
      case 'aprovado':
        statusColor = Colors.green;
        break;
      case 'reprovado':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

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
                report["status_atendimento"],
                style: TextStyle(
                  color: statusColor,
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
            if (report["origem"] == "atendimento") {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => UsuarioDetalhe(idUsuario: report["id"]),
              //   ),
              // );
              print("clicou no atendimento");
            } else {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => UsuarioDetalhe(idUsuario: report["id"]),
              //   ),
              // );
              print("clicou na clinica");
            }
          },
        ),
        const Divider(),
      ],
    );
  }
}
