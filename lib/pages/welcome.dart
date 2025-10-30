import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double _logoOpacity = 0.0;
  double _textOpacity = 0.0;
  Offset _textOffset = const Offset(0, 0.2);

  @override
  void initState() {
    super.initState();

    // Primeiro o logo aparece
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _logoOpacity = 1.0;
      });
    });

    // Depois o texto desliza suavemente para cima
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _textOpacity = 1.0;
        _textOffset = Offset.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
            'O Sétimo',
            style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,)
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              tooltip: "Informações",
              onPressed: () {
                Navigator.pushNamed(context, '/info');
              },
            ),

          ],
        ),
        backgroundColor: Color(0xFF7C0A02),
        foregroundColor: Colors.white,
        
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animação do logo
            AnimatedOpacity(
              opacity: _logoOpacity,
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: SvgPicture.asset(
                'assets/icons/logo7.svg',
                height: 200,
                width: 200,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF7C0A02),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Animação do texto
            AnimatedSlide(
              offset: _textOffset,
              duration: const Duration(seconds: 1),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _textOpacity,
                duration: const Duration(milliseconds: 800),
                child: Column(
                  children: [
                    Text(
                      "O Sétimo",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: const Color(0xFF7C0A02),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "A Palavra Revelada em Simplicidade",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C0A02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 42, vertical: 20),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: const Text(
                        "Começar agora",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
