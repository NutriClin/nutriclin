import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_appbar.dart';
import 'tmb.dart';
import 'get.dart';
import 'imc.dart';

class CalculosPage extends StatelessWidget {
  const CalculosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Cálculos',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildCards(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCards(BuildContext context) {
    List<Widget> cards = [];

    cards.addAll([
      _buildCard(
        title: 'TMB',
        subtitle: 'Taxa metabólica basal',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TMBPage())),
      ),
      const SizedBox(width: 20),
      _buildCard(
        title: 'GET',
        subtitle: 'Gasto energético total',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GETPage())),
      ),
      const SizedBox(width: 20),
      _buildCard(
        title: 'IMC',
        subtitle: 'Índice de massa corporal',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IMCPage())),
      ),
    ]);

    return cards;
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.grey.withOpacity(1),
        highlightColor: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 130, // Largura aumentada de 100 para 130
          height: 120, // Altura mantida
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 50,
                offset: const Offset(0, 8),
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 3,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20, // Mantido
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007AFF),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12, // Mantido
                  color: Color(0xFF807D80),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}