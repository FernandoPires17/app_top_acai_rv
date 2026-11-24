import '../models/cliente_model.dart';
import 'clientes_service.dart';

class ClientesRepository {
  final ClientesService _service;

  ClientesRepository(this._service);

  Stream<Map<String, dynamic>> obterClientes() {
    return _service.listarClientes();
  }

  Future<void> salvarCliente(Cliente cliente) async {
    if (cliente.id == null) {
      await _service.criarCliente(cliente);
    } else {
      await _service.atualizarCliente(cliente);
    }
  }

  Future<void> deletarCliente(String id) async {
    await _service.excluirCliente(id);
  }
}