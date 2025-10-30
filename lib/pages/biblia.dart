import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BibliaPage extends StatefulWidget {
  final String? livro;
  final int? capitulo;
  final int? versiculo;

  const BibliaPage({super.key, this.livro, this.capitulo, this.versiculo});

  @override
  State<BibliaPage> createState() => _BibliaPageState();
}

class _BibliaPageState extends State<BibliaPage> {

  OverlayEntry? _overlayEntry;
  int? _versiculoSelecionado;
  Map<String, bool> _versiculosDestacados = {};

  String _gerarChave(String livro, int capitulo, int versiculo) {
    return "$livro-$capitulo-$versiculo";
  }


  void _removerOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _mostrarOpcoesVersiculo(BuildContext context, Offset position, int numero, String chave) {
    _removerOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy - 50,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _versiculosDestacados[chave] = !(_versiculosDestacados[chave] ?? false);
                      _salvarDestaques();
                    });
                    _removerOverlay();
                  },
                  child: const Text("Destacar"),
                ),
                TextButton(
                  onPressed: () {
                    final textoVersiculo = _verseText.split(RegExp(r'(\d+\s)')).firstWhere(
                          (v) => v.contains(numero as Pattern),
                      orElse: () => "",
                    );
                    Clipboard.setData(ClipboardData(text: textoVersiculo));
                    _removerOverlay();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Versículo copiado!")),
                    );
                  },
                  child: const Text("Copiar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _salvarDestaques() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('destaquesBiblia', jsonEncode(_versiculosDestacados));
  }

  Future<void> _carregarDestaques() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('destaquesBiblia');
    if (jsonString != null) {
      setState(() {
        _versiculosDestacados = Map<String, bool>.from(jsonDecode(jsonString));
      });
    }
  }

  Future<void> _salvarTamanhoFonte(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tamanhoFonteBiblia', valor);
  }

  Future<void> _carregarTamanhoFonte() async {
    final prefs = await SharedPreferences.getInstance();
    final tamanhoSalvo = prefs.getDouble('tamanhoFonteBiblia');
    if (tamanhoSalvo != null) {
      setState(() {
        _fontSize = tamanhoSalvo;
      });
    }
  }

  String _verseText = "Selecione um livro e capítulo";
  bool _loading = false;

  double _fontSize = 18.0;

  final String _token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdHIiOiJNb24gT2N0IDEzIDIwMjUgMTI6NTY6MTEgR01UKzAwMDAudGhpYWdvY3NhbHZlczAzQGdtYWlsLmNvbSIsImlhdCI6MTc2MDM2MDE3MX0.DeKfGyr_aFwu_nf-Nsq3W_i-LDQ_F_iFF6eiLDrFQcs";

  final List<String> versoesDisponiveis = [
    "acf",
    "ara",
    "nvi",
    "apee",
    "bbe",
    "kjv",
    "rvr",
  ];
  String versaoSelecionada = "acf";

  final List<Map<String, String>> livros = [
    {"abbrev": "gn", "name": "Gênesis"},
    {"abbrev": "ex", "name": "Êxodo"},
    {"abbrev": "lv", "name": "Levítico"},
    {"abbrev": "nm", "name": "Números"},
    {"abbrev": "dt", "name": "Deuteronômio"},
    {"abbrev": "js", "name": "Josué"},
    {"abbrev": "jc", "name": "Juízes"},
    {"abbrev": "rt", "name": "Rute"},
    {"abbrev": "1sm", "name": "1 Samuel"},
    {"abbrev": "2sm", "name": "2 Samuel"},
    {"abbrev": "1rs", "name": "1 Reis"},
    {"abbrev": "2rs", "name": "2 Reis"},
    {"abbrev": "1cr", "name": "1 Crônicas"},
    {"abbrev": "2cr", "name": "2 Crônicas"},
    {"abbrev": "es", "name": "Esdras"},
    {"abbrev": "ne", "name": "Neemias"},
    {"abbrev": "et", "name": "Ester"},
    {"abbrev": "jó", "name": "Jó"},
    {"abbrev": "sl", "name": "Salmos"},
    {"abbrev": "pv", "name": "Provérbios"},
    {"abbrev": "ec", "name": "Eclesiastes"},
    {"abbrev": "ct", "name": "Cânticos"},
    {"abbrev": "is", "name": "Isaías"},
    {"abbrev": "jr", "name": "Jeremias"},
    {"abbrev": "lm", "name": "Lamentações"},
    {"abbrev": "ez", "name": "Ezequiel"},
    {"abbrev": "dn", "name": "Daniel"},
    {"abbrev": "os", "name": "Oseias"},
    {"abbrev": "jl", "name": "Joel"},
    {"abbrev": "am", "name": "Amós"},
    {"abbrev": "ob", "name": "Obadias"},
    {"abbrev": "jn", "name": "Jonas"},
    {"abbrev": "mq", "name": "Miquéias"},
    {"abbrev": "na", "name": "Naum"},
    {"abbrev": "hc", "name": "Habacuque"},
    {"abbrev": "sf", "name": "Sofonias"},
    {"abbrev": "ag", "name": "Ageu"},
    {"abbrev": "zc", "name": "Zacarias"},
    {"abbrev": "ml", "name": "Malaquias"},
    {"abbrev": "mt", "name": "Mateus"},
    {"abbrev": "mc", "name": "Marcos"},
    {"abbrev": "lc", "name": "Lucas"},
    {"abbrev": "jo", "name": "João"},
    {"abbrev": "at", "name": "Atos"},
    {"abbrev": "rm", "name": "Romanos"},
    {"abbrev": "1co", "name": "1 Coríntios"},
    {"abbrev": "2co", "name": "2 Coríntios"},
    {"abbrev": "gl", "name": "Gálatas"},
    {"abbrev": "ef", "name": "Efésios"},
    {"abbrev": "fp", "name": "Filipenses"},
    {"abbrev": "cl", "name": "Colossenses"},
    {"abbrev": "1ts", "name": "1 Tessalonicenses"},
    {"abbrev": "2ts", "name": "2 Tessalonicenses"},
    {"abbrev": "1tm", "name": "1 Timóteo"},
    {"abbrev": "2tm", "name": "2 Timóteo"},
    {"abbrev": "tt", "name": "Tito"},
    {"abbrev": "fm", "name": "Filemom"},
    {"abbrev": "hb", "name": "Hebreus"},
    {"abbrev": "tg", "name": "Tiago"},
    {"abbrev": "1pe", "name": "1 Pedro"},
    {"abbrev": "2pe", "name": "2 Pedro"},
    {"abbrev": "1jo", "name": "1 João"},
    {"abbrev": "2jo", "name": "2 João"},
    {"abbrev": "3jo", "name": "3 João"},
    {"abbrev": "jd", "name": "Judas"},
    {"abbrev": "ap", "name": "Apocalipse"},
  ];

  Map<String, int> capitulosPorLivro = {};
  String? livroSelecionado;
  int? capituloSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarTamanhoFonte();
    _carregarDestaques();
    capitulosPorLivro = {
      "gn": 50,
      "ex": 40,
      "lv": 27,
      "nm": 36,
      "dt": 34,
      "js": 24,
      "jc": 21,
      "rt": 4,
      "1sm": 31,
      "2sm": 24,
      "1rs": 22,
      "2rs": 25,
      "1cr": 29,
      "2cr": 36,
      "es": 10,
      "ne": 13,
      "et": 10,
      "jó": 42,
      "sl": 150,
      "pv": 31,
      "ec": 12,
      "ct": 8,
      "is": 66,
      "jr": 52,
      "lm": 5,
      "ez": 48,
      "dn": 12,
      "os": 14,
      "jl": 3,
      "am": 9,
      "ob": 1,
      "jn": 4,
      "mq": 7,
      "na": 3,
      "hc": 3,
      "sf": 3,
      "ag": 2,
      "zc": 14,
      "ml": 4,
      "mt": 28,
      "mc": 16,
      "lc": 24,
      "jo": 21,
      "at": 28,
      "rm": 16,
      "1co": 16,
      "2co": 13,
      "gl": 6,
      "ef": 6,
      "fp": 4,
      "cl": 4,
      "1ts": 5,
      "2ts": 3,
      "1tm": 6,
      "2tm": 4,
      "tt": 3,
      "fm": 1,
      "hb": 13,
      "tg": 5,
      "1pe": 5,
      "2pe": 3,
      "1jo": 5,
      "2jo": 1,
      "3jo": 1,
      "jd": 1,
      "ap": 22,
    };

    // Novo: inicializa direto no versículo recebido do HomePage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.livro != null && widget.capitulo != null) {
        final livroEncontrado = livros.firstWhere(
          (l) => l['name']!.toLowerCase() == widget.livro!.toLowerCase(),
          orElse: () => {},
        );
        if (livroEncontrado.isNotEmpty) {
          setState(() {
            livroSelecionado = livroEncontrado['abbrev'];
            capituloSelecionado = widget.capitulo!;
          });
          fetchVerse();
        }
      }
    });
  }

  String formatarVersiculos(String texto) {
    return texto
        .replaceAllMapped(RegExp(r'(\d+)\s'), (match) => '\n${match.group(1)} ')
        .trim();
  }

  Future<void> fetchVerse() async {
    if (livroSelecionado == null || capituloSelecionado == null) return;

    setState(() {
      _loading = true;
      _verseText = "Carregando...";
    });

    final url = Uri.parse(
      "https://www.abibliadigital.com.br/api/verses/$versaoSelecionada/$livroSelecionado/$capituloSelecionado",
    );

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
        if (data['verses'] != null) {
          final verses = data['verses'] as List;
          final text = verses
              .map((v) => "${v['number']} ${v['text']}")
              .join(" ");
          setState(() {
            _verseText = formatarVersiculos(text);
          });
        } else {
          setState(() {
            _verseText = "Nenhum versículo encontrado.";
          });
        }
      } else {
        setState(() {
          _verseText =
              "Erro ao carregar (${response.statusCode}): ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _verseText = "Falha na conexão: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _abrirConfigLeitura() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        double valorTemporario = _fontSize;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Ajustar tamanho do texto",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Slider(
                    value: valorTemporario,
                    min: 14,
                    max: 28,
                    divisions: 7,
                    label: "${valorTemporario.toStringAsFixed(0)} pt",
                    onChanged: (val) {
                      setModalState(() => valorTemporario = val);
                      setState(() => _fontSize = val);
                      _salvarTamanhoFonte(val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔹 Título da página
            Text(
              "Bíblia",
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            // 🔹 Linha com versão + ícone de pesquisa
            Row(
              children: [
                // Ícone de pesquisa
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
                ), // Botão de versão (Dropdown compacto)
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: versaoSelecionada,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    dropdownColor: Theme.of(context).colorScheme.primary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    items: versoesDisponiveis
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text(v.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (novaVersao) {
                      if (novaVersao != null) {
                        setState(() {
                          versaoSelecionada = novaVersao;
                        });
                        fetchVerse(); // atualiza versão
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirConfigLeitura,
        child: const Icon(Icons.text_fields),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: livros.map((livro) {
                  final selected = livro['abbrev'] == livroSelecionado;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(livro['name']!),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          livroSelecionado = livro['abbrev'];
                          capituloSelecionado = 1;
                        });
                        fetchVerse();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            if (livroSelecionado != null)
              SizedBox(
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(
                    capitulosPorLivro[livroSelecionado!]!,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text("${index + 1}"),
                        selected: capituloSelecionado == index + 1,
                        onSelected: (_) {
                          setState(() {
                            capituloSelecionado = index + 1;
                          });
                          fetchVerse();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: _fontSize, height: 1.8),
                          children: _buildVersesSpans(_verseText),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildVersesSpans(String text) {
    final regex = RegExp(r'(\d+)\s([^\d]+)');
    final matches = regex.allMatches(text);

    List<TextSpan> spans = [];
    for (var match in matches) {
      final numero = int.parse(match.group(1)!);
      final conteudo = match.group(2)!;
      final chave = _gerarChave(livroSelecionado!, capituloSelecionado!, numero);

      spans.add(
        TextSpan(
          text: '\n$numero ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );

      // Conteúdo do versículo com GestureRecognizer
      spans.add(
        TextSpan(
          text: "${conteudo.trim()} ",
          style: TextStyle(
            fontSize: _fontSize,
            height: 1.8,
            backgroundColor: _versiculosDestacados[chave] == true
                ? Colors.yellow[200]
                : Colors.transparent,
          ),
          recognizer: TapGestureRecognizer()
            ..onTapDown = (details) {
              _mostrarOpcoesVersiculo(context, details.globalPosition, numero, chave);
            },
        ),
      );
    }
    return spans;
  }

  @override
  void dispose() {
    _removerOverlay();
    super.dispose();
  }
}
