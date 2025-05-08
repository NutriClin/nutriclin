import 'package:flutter/material.dart';
import 'package:nutri_app/pages/relatorios/professor/relatorio_professor_identificacao.dart';

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
      case 'rejeitado':
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RelatorioProfessorIdentificacaoPage(
                    atendimentoId: report["id"],
                    isHospital: true, // Indica que é hospital
                  ),
                ),
              );
            } else if (report["origem"] == "clinica") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RelatorioProfessorIdentificacaoPage(
                    atendimentoId: report["id"],
                    isHospital: false, // Indica que é clínica
                  ),
                ),
              );
            }
          },
        ),
        const Divider(),
      ],
    );
  }
}