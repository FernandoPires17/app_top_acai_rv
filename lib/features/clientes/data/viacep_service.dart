import 'dart:convert';
import 'package:http/http.dart' as http;

class ViaCepService {
  // Método que busca o endereço no ViaCEP
  Future<Map<String, dynamic>?> buscarCep(String cep) async {
    // Limpa o CEP, deixando só números
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cepLimpo.length != 8) {
      throw Exception('CEP inválido. Digite 8 números.');
    }

    final url = Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/');

    try {
      // Aplica um timeout de 10 segundos para não travar o app
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // O ViaCEP retorna {"erro": true} quando o CEP não existe
        if (data.containsKey('erro') && data['erro'] == true) {
          throw Exception('CEP não encontrado.');
        }

        return data; // Retorna o JSON com rua, bairro, etc.
      } else {
        throw Exception('Serviço indisponível no momento.');
      }
    } catch (e) {
      // Se der timeout ou erro de rede, cai aqui
      throw Exception('Falha na conexão. Verifique sua internet.');
    }
  }
}