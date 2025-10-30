import 'package:flutter/material.dart';
import 'package:osetimo_app/pages/sermoes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'biblia.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String versiculoDoDia = "Carregando versículo do dia...";
  bool _loading = true;

  // Dados do versículo
  String? _livro;
  int? _capitulo;
  int? _numero;

  final String _token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdHIiOiJNb24gT2N0IDEzIDIwMjUgMTI6NTY6MTEgR01UKzAwMDAudGhpYWdvY3NhbHZlczAzQGdtYWlsLmNvbSIsImlhdCI6MTc2MDM2MDE3MX0.DeKfGyr_aFwu_nf-Nsq3W_i-LDQ_F_iFF6eiLDrFQcs";
  final String versao = "acf";

  @override
  void initState() {
    super.initState();
    carregarVersiculoDiario();
  }

  Future<void> carregarVersiculoDiario() async {
    final prefs = await SharedPreferences.getInstance();
    final hoje = DateTime.now();
    final hojeString = "${hoje.year}-${hoje.month}-${hoje.day}";

    final versiculoSalvoData = prefs.getString('versiculoData');
    final versiculoSalvoTexto = prefs.getString('versiculoTexto');

    if (versiculoSalvoData == hojeString && versiculoSalvoTexto != null) {
      // Recupera também os dados de localização
      setState(() {
        versiculoDoDia = versiculoSalvoTexto;
        _livro = prefs.getString('livro');
        _capitulo = prefs.getInt('capitulo');
        _numero = prefs.getInt('versiculo');
        _loading = false;
      });
    } else {
      // Buscar versículo aleatório
      await fetchVersiculoDoDia();
      // Salvar versículo com a data de hoje
      await prefs.setString('versiculoData', hojeString);
      await prefs.setString('versiculoTexto', versiculoDoDia);
      if (_livro != null && _capitulo != null && _numero != null) {
        await prefs.setString('livro', _livro!);
        await prefs.setInt('capitulo', _capitulo!);
        await prefs.setInt('versiculo', _numero!);
      }
    }
  }

  Future<void> fetchVersiculoDoDia() async {
    setState(() => _loading = true);

    final url =
    Uri.parse("https://www.abibliadigital.com.br/api/verses/$versao/random");

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _livro = data['book']['name'];
          _capitulo = data['chapter'];
          _numero = data['number'];
          versiculoDoDia =
          "${data['book']['name']} ${data['chapter']}:${data['number']}\n${data['text']}";
        });
      } else {
        setState(() {
          versiculoDoDia =
          "Erro ao carregar versículo (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        versiculoDoDia = "Falha na conexão: $e";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _abrirBiblia() {
    if (_livro != null && _capitulo != null && _numero != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BibliaPage(
            livro: _livro!,
            capitulo: _capitulo!,
            versiculo: _numero!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Versículo ainda não carregado.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "O Sétimo",
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_note, color: Colors.white),
                  tooltip: "Anotações",
                  onPressed: () {
                    Navigator.pushNamed(context, '/notas');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  tooltip: "Pesquisar versículos",
                  onPressed: () {
                    Navigator.pushNamed(context, '/pesquisa');
                  },
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFfff9e5),
              Color(0xFFbe8e8e),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Versículo do Dia para Você!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),

                // Card do versículo do dia com GestureDetector
                GestureDetector(
                  onTap: _abrirBiblia,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : Text(
                        versiculoDoDia,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "O que você vai ler hoje?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Card Bíblia
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BibliaPage()),
                        );
                      },
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SizedBox(
                            width: 120,
                            height: 140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/HolyBibleIcon.png",
                                  width: 100,
                                  height: 100,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Bíblia",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Card Mensagens
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SermoesPage()),
                        );
                      },
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SizedBox(
                            width: 120,
                            height: 140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/LogoProfetaW&B.png",
                                  width: 100,
                                  height: 100,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Mensagens",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
