import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class SermoesPage extends StatefulWidget {
  const SermoesPage({super.key});

  @override
  State<SermoesPage> createState() => _SermoesPageState();
}

class _SermoesPageState extends State<SermoesPage> {
  List<Map<String, dynamic>> sermoes = []; // Lista para armazenar os sermões

  @override
  void initState() {
    super.initState();
    carregarJson(); // Carrega os dados do JSON ao iniciar
  }

  Future<void> carregarJson() async {
    final arquivos = [
      '19580108_A_ESCRITURA_NA_PAREDE.json',
      '19651031_Poder_De_Transformação.json'
    ];

    List<Map<String, dynamic>> listaSermoes = [];

    for (var arquivo in arquivos) {
      final String jsonString = await rootBundle.loadString(
          'lib/sermoes_txt/$arquivo');
      final Map<String, dynamic> dados = jsonDecode(jsonString);
      listaSermoes.add(dados);
    }

    setState(() {
      sermoes = listaSermoes;
    });

    print('Sermões carregados: ${sermoes.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Sermões",
              style: Theme
                  .of(context)
                  .appBarTheme
                  .titleTextStyle
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  tooltip: "Pesquisar versículos",
                  onPressed: () {
                    Navigator.pushNamed(context, '/pesquisa');
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_note, color: Colors.white),
                  tooltip: "Anotações",
                  onPressed: () {
                    Navigator.pushNamed(context, '/notas');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: sermoes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: sermoes.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(sermoes[index]['titulo'] ?? 'Sem título'),
                subtitle: Text(
                  sermoes[index]['subtitulo'] ?? 'Sem subtítulo',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.left,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SermaoDetailPage(
                            titulo: sermoes[index]['titulo'] ?? 'Sem título',
                            subtitulo: sermoes[index]['subtitulo'] ??
                                'Sem subtítulo',
                            data: sermoes[index]['data'] ?? 'Sem data',
                            conteudo: sermoes[index]['texto'] ?? 'Sem conteúdo',
                          ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
// Página de detalhe do sermão
class SermaoDetailPage extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String conteudo;
  final String data;

  const SermaoDetailPage({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.conteudo,
    required this.data
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titulo),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  tooltip: "Pesquisar versículos",
                  onPressed: () {
                     Navigator.pushNamed(context, '/pesquisa');
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_note, color: Colors.white),
                  tooltip: "Anotações",
                  onPressed: () {
                    Navigator.pushNamed(context, '/notas');
                  },
                ),
              ]
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                subtitulo,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text(
              conteudo,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
              ),
            ]
          )
        ),
      ),
    );
  }
}
