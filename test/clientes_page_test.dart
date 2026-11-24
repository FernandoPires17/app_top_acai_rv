import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app_top_acai_rv/features/clientes/view/clientes_page.dart';
import 'package:app_top_acai_rv/features/clientes/view_model/clientes_view_model.dart';
import 'package:app_top_acai_rv/features/clientes/data/clientes_repository.dart';
import 'package:app_top_acai_rv/features/clientes/data/clientes_service.dart';
import 'package:app_top_acai_rv/features/clientes/models/cliente_model.dart';

class FakeServiceWidget implements ClientesService {
  @override
  Stream<Map<String, dynamic>> listarClientes() {
    // A CORREÇÃO ESTÁ AQUI TAMBÉM
    return Stream.value({'clientes': <Cliente>[], 'doCache': true});
  }
  @override
  Future<void> criarCliente(cliente) async {}
  @override
  Future<void> atualizarCliente(cliente) async {}
  @override
  Future<void> excluirCliente(String id) async {}
}

void main() {
  testWidgets('Deve mostrar o banner de Modo Offline quando doCache for verdadeiro', (tester) async {
    final service = FakeServiceWidget();
    final repository = ClientesRepository(service);
    final viewModel = ClientesViewModel(repository);

    await tester.pumpWidget(
      ChangeNotifierProvider<ClientesViewModel>.value(
        value: viewModel,
        child: const MaterialApp(home: ClientesPage()),
      ),
    );

    // Como o Fake retorna o cache imediatamente, damos um pump para atualizar a tela
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Modo Offline: Exibindo dados salvos.'), findsOneWidget);
  });
}