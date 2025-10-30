import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Nota {
  final String titulo;
  final String conteudo;
  final DateTime data;

  Nota({required this.titulo, required this.conteudo, required this.data});

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'conteudo': conteudo,
    'data': data.toIso8601String(),
  };

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      titulo: json['titulo'],
      conteudo: json['conteudo'],
      data: DateTime.parse(json['data']),
    );
  }
}

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  List<Nota> _notas = [];

  @override
  void initState() {
    super.initState();
    _carregarNotas();
  }

  String _extrairTexto(String conteudoJson) {
    try {
      final decoded = jsonDecode(conteudoJson);

      // Se o conteúdo for realmente um Delta do Quill, extrai o texto puro
      if (decoded is List) {
        final delta = Delta.fromJson(decoded);
        final buffer = StringBuffer();

        for (var op in delta.toList()) {
          if (op.data is String) buffer.write(op.data);
        }

        return buffer.toString().trim();
      }
      // Se não for JSON válido, retorna o próprio conteúdo
      return conteudoJson;
    } catch (_) {
      return conteudoJson;
    }
  }


  Future<void> _carregarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('notas') ?? [];
    setState(() {
      _notas = data.map((n) => Nota.fromJson(jsonDecode(n))).toList()
        ..sort((a, b) => b.data.compareTo(a.data)); // mais recente primeiro
    });
  }

  Future<void> _salvarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _notas.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList('notas', data);
  }

  void _adicionarNota(String titulo, String conteudo) {
    final nova = Nota(titulo: titulo, conteudo: conteudo, data: DateTime.now());
    setState(() {
      _notas.insert(0, nova);
    });
    _salvarNotas();
  }

  void _removerNota(int index) {
    setState(() {
      _notas.removeAt(index);
    });
    _salvarNotas();
  }

  void _abrirNovaNota() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final tituloController = TextEditingController();
        final conteudoController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: conteudoController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Conteúdo'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (tituloController.text.isEmpty ||
                      conteudoController.text.isEmpty) return;
                  _adicionarNota(
                    tituloController.text.trim(),
                    conteudoController.text.trim(),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('Salvar nota'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Agora a função espera um resultado da rota de detalhes:
  void _abrirNotaDetalhe(Nota nota) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotaDetalhePage(
          nota: nota,
          onAtualizar: (notaAtualizada) {
            setState(() {
              final index = _notas.indexOf(nota);
              if (index != -1) {
                _notas[index] = notaAtualizada;
                _notas.sort((a, b) => b.data.compareTo(a.data));
              }
            });
            _salvarNotas();
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        centerTitle: false,
      ),
      body: _notas.isEmpty
          ? const Center(child: Text('Nenhuma nota ainda. Comece estudando!'))
          : ListView.builder(
        itemCount: _notas.length,
        itemBuilder: (context, index) {
          final nota = _notas[index];
          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 3,
            child: ListTile(
              title: Text(
                nota.titulo,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                _extrairTexto(nota.conteudo) +
                '\n\n${nota.data.day}/${nota.data.month}/${nota.data.year}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _abrirNotaDetalhe(nota),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removerNota(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNovaNota,
        child: const Icon(Icons.add),
      ),
    );
  }

  // a página que chamou decide se precisa fechar detalhes).
  void _editarNota(Nota notaAntiga) {
    final tituloController = TextEditingController(text: notaAntiga.titulo);
    final conteudoController = TextEditingController(text: notaAntiga.conteudo);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Editar nota",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: conteudoController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Conteúdo'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  final novoTitulo = tituloController.text.trim();
                  final novoConteudo = conteudoController.text.trim();
                  if (novoTitulo.isEmpty || novoConteudo.isEmpty) return;

                  final novaNota = Nota(
                    titulo: novoTitulo,
                    conteudo: novoConteudo,
                    data: DateTime.now(),
                  );

                  // Substitui a nota antiga pela nova
                  setState(() {
                    final index = _notas.indexOf(notaAntiga);
                    if (index != -1) {
                      _notas[index] = novaNota;
                      // opcional: manter ordenação por data mais recente
                      _notas.sort((a, b) => b.data.compareTo(a.data));
                    }
                  });
                  _salvarNotas();
                  Navigator.pop(context); // fecha bottom sheet
                },
                icon: const Icon(Icons.save),
                label: const Text('Salvar alterações'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class NotaDetalhePage extends StatefulWidget {
  final Nota nota;
  final Function(Nota) onAtualizar;
  const NotaDetalhePage({
    super.key,
    required this.nota,
    required this.onAtualizar,
  });

  @override
  State<NotaDetalhePage> createState() => _NotaDetalhePageState();
}

class _NotaDetalhePageState extends State<NotaDetalhePage> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    try {
      final docJson = jsonDecode(widget.nota.conteudo);
      _controller = QuillController(
        document: Document.fromDelta(Delta.fromJson(docJson)),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      _controller = QuillController.basic();
      _controller.document.insert(0, widget.nota.conteudo);
    }
  }

  Future<void> _salvar() async {
    final novoConteudo = jsonEncode(_controller.document.toDelta().toJson());
    final notaAtualizada = Nota(
      titulo: widget.nota.titulo,
      conteudo: novoConteudo,
      data: DateTime.now(),
    );

    widget.onAtualizar(notaAtualizada);

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('notas') ?? [];
    final notas = data.map((n) => Nota.fromJson(jsonDecode(n))).toList();
    final index = notas.indexWhere((n) => n.titulo == widget.nota.titulo);
    if (index != -1) notas[index] = notaAtualizada;
    await prefs.setStringList('notas', notas.map((n) => jsonEncode(n.toJson())).toList());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota salva com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nota.titulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _salvar,
            tooltip: 'Salvar nota',
          ),
        ],
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(
              showAlignmentButtons: false,
              showBackgroundColorButton: true,
            ),
          ),
          Divider(),
          Expanded(
            child: QuillEditor(
              controller: _controller,
              scrollController: ScrollController(),
              focusNode: FocusNode(),
              config: QuillEditorConfig(
                padding: const EdgeInsets.all(8),
                placeholder: 'Escreva suas anotações aqui...',
                embedBuilders: FlutterQuillEmbeds.editorBuilders(
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


