import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PesquisaPage extends StatefulWidget {
  const PesquisaPage({super.key});

  @override
  State<PesquisaPage> createState() => _PesquisaPageState();
}

class _PesquisaPageState extends State<PesquisaPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  List<dynamic> _resultadosBiblia = [];
  List<dynamic> _resultadosSermoes = [];
  List<Map<String, dynamic>> _resultadosNotas = [];

  late TabController _tabController;

  final String _token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdHIiOiJNb24gT2N0IDEzIDIwMjUgMTI6NTY6MTEgR01UKzAwMDAudGhpYWdvY3NhbHZlczAzQGdtYWlsLmNvbSIsImlhdCI6MTc2MDM2MDE3MX0.DeKfGyr_aFwu_nf-Nsq3W_i-LDQ_F_iFF6eiLDrFQcs";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _buscarVersiculos(String termo) async {
    if (termo.isEmpty) return;

    setState(() {
      _loading = true;
      _resultadosBiblia.clear();
    });

    final url = Uri.parse(
        "https://www.abibliadigital.com.br/api/verses/search?query=$termo");

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          "version": "acf",
          "search": termo,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _resultadosBiblia = data['verses'] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Erro: ${response.statusCode} : ${response.reasonPhrase}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Falha na conexão: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _buscarSermoes(String termo) async {
    setState(() {
      _loading = true;
      _resultadosSermoes.clear();
    });

    // aqui futuramente você integrará com a base dos sermões reais
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _resultadosSermoes = [
        {"titulo": "O Terceiro Êxodo", "trecho": "O tempo está se cumprindo..."},
        {"titulo": "O Sinal", "trecho": "O sinal é o Espírito Santo..."},
      ]
          .where((s) =>
      s['titulo']!.toLowerCase().contains(termo.toLowerCase()) ||
          s['trecho']!.toLowerCase().contains(termo.toLowerCase()))
          .toList();
      _loading = false;
    });
  }

  Future<void> _buscarNotas(String termo) async {
    setState(() {
      _loading = true;
      _resultadosNotas.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('notas') ?? [];
    final notas = data
        .map((n) => jsonDecode(n) as Map<String, dynamic>)
        .toList();

    final resultados = notas.where((nota) {
      final titulo = nota['titulo']?.toString().toLowerCase() ?? '';
      final conteudo = nota['conteudo']?.toString().toLowerCase() ?? '';
      return titulo.contains(termo.toLowerCase()) ||
          conteudo.contains(termo.toLowerCase());
    }).toList();

    setState(() {
      _resultadosNotas = resultados;
      _loading = false;
    });
  }

  void _executarBusca() {
    final termo = _controller.text.trim();
    if (termo.isEmpty) return;

    switch (_tabController.index) {
      case 0:
        _buscarVersiculos(termo);
        break;
      case 1:
        _buscarSermoes(termo);
        break;
      case 2:
        _buscarNotas(termo);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesquisar"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Bíblia"),
            Tab(text: "Sermões"),
            Tab(text: "Anotações"),
          ],
          onTap: (_) => setState(() {}), // força rebuild ao trocar aba
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Digite uma palavra ou frase...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _resultadosBiblia.clear();
                      _resultadosSermoes.clear();
                      _resultadosNotas.clear();
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onSubmitted: (_) => _executarBusca(),
            ),
            const SizedBox(height: 12),

            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildResultadosBiblia(),
                    _buildResultadosSermoes(),
                    _buildResultadosNotas(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- ABA 1: Bíblia
  Widget _buildResultadosBiblia() {
    if (_resultadosBiblia.isEmpty && _controller.text.isNotEmpty) {
      return const Center(child: Text("Nenhum versículo encontrado."));
    }
    return ListView.builder(
      itemCount: _resultadosBiblia.length,
      itemBuilder: (context, index) {
        final v = _resultadosBiblia[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(
              "${v['book']['name']} ${v['chapter']}:${v['number']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(v['text']),
          ),
        );
      },
    );
  }

  // --- ABA 2: Sermões
  Widget _buildResultadosSermoes() {
    if (_controller.text.isEmpty) {
      return const Center(child: Text("Pesquise por termos nos sermões."));
    }
    if (_resultadosSermoes.isEmpty) {
      return const Center(child: Text("Nenhum sermão encontrado."));
    }
    return ListView.builder(
      itemCount: _resultadosSermoes.length,
      itemBuilder: (context, index) {
        final s = _resultadosSermoes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(
              s['titulo'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(s['trecho']),
            leading: const Icon(Icons.menu_book_outlined),
            onTap: () {
              // futuramente abrir o sermão completo
            },
          ),
        );
      },
    );
  }

  // --- ABA 3: Notas
  Widget _buildResultadosNotas() {
    if (_controller.text.isEmpty) {
      return const Center(child: Text("Pesquise dentro de suas anotações."));
    }
    if (_resultadosNotas.isEmpty) {
      return const Center(child: Text("Nenhuma anotação encontrada."));
    }
    return ListView.builder(
      itemCount: _resultadosNotas.length,
      itemBuilder: (context, index) {
        final n = _resultadosNotas[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(
              n['titulo'] ?? '(Sem título)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              n['conteudo'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            leading: const Icon(Icons.note_alt_outlined),
          ),
        );
      },
    );
  }
}
