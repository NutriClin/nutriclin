import 'package:flutter/material.dart';

class CustomListRelatorio extends StatelessWidget {
  final Map<String, dynamic> report;

  const CustomListRelatorio({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    bool isPendente = report["status"] == "Pendente";
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
                report["status"],
                style: TextStyle(
                  color: isPendente ? Colors.red : Colors.green,
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
          onTap: () {},
        ),
        const Divider(),
      ],
    );
  }
}
