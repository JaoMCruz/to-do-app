import 'package:flutter/material.dart';
import 'task_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController senhaController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
              ),
            ),
            const SizedBox(height: 20),
            

            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isEmpty || senhaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos'),
                    ),
                  );
                  return;
                }

                try {
                  final userCredential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: senhaController.text.trim(),
                  );

                  print("LOGADO: ${userCredential.user?.email}");

                  if (!context.mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskPage(),
                    ),
                  );

                } on FirebaseAuthException catch (e) {
                  String mensagem = 'Erro ao fazer login';

                  if (e.code == 'user-not-found') {
                    mensagem = 'Usuário não encontrado';
                  } else if (e.code == 'wrong-password') {
                    mensagem = 'Senha incorreta';
                  } else if (e.code == 'invalid-email') {
                    mensagem = 'Email inválido';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(mensagem)),
                  );
                }
              },
              child: const Text('Entrar'),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              },
              child: const Text("Criar conta"),
            ),
          ],
        ),
      ),
    );
  }
}