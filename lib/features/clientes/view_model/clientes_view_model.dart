import 'package:flutter/material.dart';
import '../data/clientes_repository.dart';
import '../models/cliente_model.dart';

enum ClientesState { loading, success, empty, error }

class ClientesViewModel extends ChangeNotifier {
  final ClientesRepository _repository;

  ClientesViewModel(this._repository) {
    carregarClientes();
  }

  ClientesState _state = ClientesState.loading;
  String _errorMessage = '';
  List<Cliente> _clientes = [];
  bool _isFromCache = false; // NOVO: Diz se os dados são do cache

  ClientesState get state => _state;
  String get errorMessage => _errorMessage;
  List<Cliente> get clientes => _clientes;
  bool get isFromCache => _isFromCache;

  void carregarClientes() {
    _state = ClientesState.loading;
    notifyListeners();

    _repository.obterClientes().listen((data) {
      _clientes = data['clientes'];
      _isFromCache = data['doCache'];
      _state = _clientes.isEmpty ? ClientesState.empty : ClientesState.success;
      notifyListeners();
    }, onError: (e) {
      _state = ClientesState.error;
      _errorMessage = 'Erro ao carregar clientes. Verifique sua conexão.';
      notifyListeners();
    });
  }

  Future<bool> salvarCliente(Cliente cliente) async {
    try {
      await _repository.salvarCliente(cliente);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletarCliente(String id) async {
    try {
      await _repository.deletarCliente(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}