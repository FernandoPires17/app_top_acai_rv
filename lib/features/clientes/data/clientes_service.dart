import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cliente_model.dart';

class ClientesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _clientesRef => _firestore.collection('clientes');

  // Retorna um Map com a lista e a origem dos dados (cache ou rede)
  Stream<Map<String, dynamic>> listarClientes() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value({'clientes': [], 'doCache': false});

    return _clientesRef
        .where('ownerId', isEqualTo: uid)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      final clientes = snapshot.docs.map((doc) {
        return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      final doCache = snapshot.metadata.isFromCache;

      return {'clientes': clientes, 'doCache': doCache};
    });
  }

  Future<void> criarCliente(Cliente cliente) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não logado');

    cliente.ownerId = uid;

    await _clientesRef.add(cliente.toMap());
  }

  Future<void> atualizarCliente(Cliente cliente) async {
    if (cliente.id == null) return;
    await _clientesRef.doc(cliente.id).update(cliente.toMap());
  }

  Future<void> excluirCliente(String id) async {
    await _clientesRef.doc(id).delete();
  }
}