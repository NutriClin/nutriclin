// import 'package:flutter/material.dart';
// import '../components/custom_header.dart';

// class TMBPage extends StatefulWidget {
//   const TMBPage({super.key});

//   @override
//   _TMBPageState createState() => _TMBPageState();
// }

// class _TMBPageState extends State<TMBPage> {
//   bool isMale = true; 
//   final TextEditingController ageController = TextEditingController();
//   final TextEditingController weightController = TextEditingController();
//   final TextEditingController heightController = TextEditingController();
//   double result = 0.0;

//   void calculateTMB() {
//     setState(() {
//       int age = int.tryParse(ageController.text) ?? 0;
//       double weight = double.tryParse(weightController.text) ?? 0;
//       double height = double.tryParse(heightController.text) ?? 0;

//       if (age > 0 && weight > 0 && height > 0) {
//         if (isMale) {
//           result = 66 + (13.7 * weight) + (5 * height) - (6.8 * age);
//         } else {
//           result = 655 + (9.6 * weight) + (1.8 * height) - (4.7 * age);
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomHeader(title: 'Cálculo TMB'),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'Sexo:',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Checkbox(
//                   value: isMale,
//                   onChanged: (value) {
//                     setState(() {
//                       isMale = true;
//                     });
//                   },
//                 ),
//                 const Text('Masculino'),
//                 Checkbox(
//                   value: !isMale,
//                   onChanged: (value) {
//                     setState(() {
//                       isMale = false;
//                     });
//                   },
//                 ),
//                 const Text('Feminino'),
//               ],
//             ),

//             const SizedBox(height: 10),

//             TextField(
//               controller: ageController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Idade',
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 10),

//             TextField(
//               controller: weightController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Peso corporal (kg)',
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 10),

//             TextField(
//               controller: heightController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Estatura (cm)',
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 20),

//             TextField(
//               readOnly: true,
//               decoration: InputDecoration(
//                 labelText: 'Resultado',
//                 border: const OutlineInputBorder(),
//                 hintText: result == 0.0 ? '' : result.toStringAsFixed(2),
//               ),
//             ),

//             const SizedBox(height: 30),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child: const Text('Sair'),
//                 ),
//                 ElevatedButton(
//                   onPressed: calculateTMB,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                   child: const Text('Calcular'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
