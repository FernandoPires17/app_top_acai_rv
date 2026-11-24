class Cliente {
  String? id;
  String ownerId;
  String nome;
  String telefone;
  String email;
  String endereco;
  String bairro;
  String cep;
  String? fotoPath;

  Cliente({
    this.id,
    required this.ownerId,
    required this.nome,
    required this.telefone,
    required this.email,
    required this.endereco,
    required this.bairro,
    required this.cep,
    this.fotoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'bairro': bairro,
      'cep': cep,
      'fotoPath': fotoPath,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map, String documentId) {
    return Cliente(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      nome: map['nome'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'] ?? '',
      endereco: map['endereco'] ?? '',
      bairro: map['bairro'] ?? '',
      cep: map['cep'] ?? '',
      fotoPath: map['fotoPath'],
    );
  }
}