import 'package:flutter_test/flutter_test.dart';
import 'package:app_top_acai_rv/features/clientes/data/clientes_repository.dart';
import 'package:app_top_acai_rv/features/clientes/data/clientes_service.dart';
import 'package:app_top_acai_rv/features/clientes/models/cliente_model.dart'; // Import necessário
import 'package:app_top_acai_rv/features/clientes/view_model/clientes_view_model.dart';

class FakeClientesService implements ClientesService {
  @override
  Stream<Map<String, dynamic>> listarClientes() {
    // A CORREÇÃO ESTÁ AQUI: Tipamos a lista vazia como <Cliente>[]
    return Stream.value({'clientes': <Cliente>[], 'doCache': false});
  }

  @override
  Future<void> criarCliente(cliente) async {}
  @override
  Future<void> atualizarCliente(cliente) async {}
  @override
  Future<void> excluirCliente(String id) async {}
}

void main() {
  group('ClientesViewModel', () {
    test('Deve emitir estado EMPTY quando a lista de clientes estiver vazia', () async {
      final service = FakeClientesService();
      final repository = ClientesRepository(service);
      final viewModel = ClientesViewModel(repository);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.state, ClientesState.empty);
    });
  });
}