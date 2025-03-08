import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_input.dart';
import '../home.dart';
import 'components/custom_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'components/custom_card.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth < 600
        ? screenWidth * 0.9 // Em telas pequenas (celular), 90% da largura
        : screenWidth * 0.4; // Em telas maiores, 40% da largura

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Logo
                      SizedBox(
                        width: 400,
                        height: 400,
                        child: SvgPicture.asset(
                          'assets/imagens/campologo.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),

                      CustomCard(
                        width: cardWidth,
                        child: Column(
                          children: [
                            CustomInput(label: 'RA:', width: 50),
                            const SizedBox(height: 15),
                            CustomInput(label: 'Senha:', width: 50),
                            const SizedBox(height: 15),
                            CustomButton(
                              text: "Entrar",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
