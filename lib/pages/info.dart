import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'O Sétimo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF7C0A02),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre o Aplicativo',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: const Color(0xFF7C0A02),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '''
Este aplicativo nasceu de um desejo simples, mas profundo: oferecer um espaço onde os filhos e filhas de Deus possam se aproximar mais da Palavra revelada. A ideia surgiu da necessidade de unir, em um único ambiente, recursos de estudo, leitura e meditação — tanto nas Escrituras Sagradas quanto nas mensagens do profeta William Marrion Branham.

Vivemos dias de distração constante, em que o tempo parece escapar por entre os dedos. Este projeto busca, então, resgatar um hábito precioso: o de parar, ler e ouvir o que o Espírito tem a dizer à Noiva de Cristo. Cada detalhe foi pensado para facilitar o estudo, a anotação e o crescimento espiritual, colocando a tecnologia a serviço da fé.

O objetivo principal do aplicativo é ser uma ferramenta de edificação e comunhão — um ponto de encontro entre crentes que seguem a Mensagem e também um convite para aqueles que ainda não a conhecem. Que este espaço possa servir de testemunho vivo de que Deus continua falando ao Seu povo, e que Sua Palavra, revelada e confirmada, permanece sendo o alicerce da fé cristã.

A você, que faz parte da Mensagem: este aplicativo é um lembrete de que não estamos sozinhos. Estamos espalhados pelo mundo, mas unidos por uma mesma Luz, sobrepondo as barreiras humanísticas e mantendo nosso foco no único objetivo:  SER RAPTADO!
E a você, que talvez esteja chegando agora e deseja compreender melhor o que cremos, que este seja um ponto de partida — não para seguir homens, mas para descobrir o Deus vivo que Se manifestou em carne, e hoje vive em Sua Noiva.

Que este aplicativo seja, acima de tudo, um instrumento para aproximar almas da Verdade.

Com fé e dedicação,
Thiago da Conceição Santana Alves
Desenvolvedor e idealizador do projeto

Contato: 
E-mail: revelacao.thiagoalves@gmail.com
Telefone: +55 (61) 98211-7974
              ''',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
