import 'package:flutter_test/flutter_test.dart';
import 'package:osetimo_app/main.dart'; // ajuste o nome do pacote se for diferente

void main() {
  testWidgets('Carrega a tela inicial do O Sétimo', (WidgetTester tester) async {
    // Constrói o app
    await tester.pumpWidget(const OSetimoApp());

  });
}
