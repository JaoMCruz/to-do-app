import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();

  bool obscureSenha = true;
  bool obscureConfirmar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: senhaController,
              obscureText: obscureSenha,
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureSenha ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureSenha = !obscureSenha;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: confirmarSenhaController,
              obscureText: obscureConfirmar,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmar ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmar = !obscureConfirmar;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                if (emailController.text.isEmpty ||
                    senhaController.text.isEmpty ||
                    confirmarSenhaController.text.isEmpty) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos'),
                    ),
                  );
                  return;
                }

                if (senhaController.text != confirmarSenhaController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('As senhas não coincidem'),
                    ),
                  );
                  return;
                }

                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: senhaController.text.trim(),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskPage(),
                    ),
                  );

                } on FirebaseAuthException catch (e) {
                  String mensagem = 'Erro ao cadastrar';

                  if (e.code == 'email-already-in-use') {
                    mensagem = 'Email já está em uso';
                  } else if (e.code == 'weak-password') {
                    mensagem = 'Senha muito fraca';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(mensagem)),
                  );
                }
              },
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}