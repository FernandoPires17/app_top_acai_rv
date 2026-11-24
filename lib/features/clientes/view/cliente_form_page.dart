import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // Plugin da Câmera
import 'dart:io'; // Para trabalhar com arquivos de imagem
import '../models/cliente_model.dart';
import '../view_model/clientes_view_model.dart';
import '../data/viacep_service.dart';

class ClienteFormPage extends StatefulWidget {
  final Cliente? cliente;

  const ClienteFormPage({super.key, this.cliente});

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;
  late TextEditingController _enderecoController;
  late TextEditingController _bairroController;
  late TextEditingController _cepController;

  final _viaCepService = ViaCepService();
  bool _isBuscandoCep = false;

  // Variáveis para a Foto (Recurso Nativo)
  final ImagePicker _picker = ImagePicker();
  File? _fotoSelecionada;
  String? _fotoPathAntiga;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.cliente?.nome ?? '');
    _telefoneController = TextEditingController(text: widget.cliente?.telefone ?? '');
    _emailController = TextEditingController(text: widget.cliente?.email ?? '');
    _enderecoController = TextEditingController(text: widget.cliente?.endereco ?? '');
    _bairroController = TextEditingController(text: widget.cliente?.bairro ?? '');
    _cepController = TextEditingController(text: widget.cliente?.cep ?? '');

    _fotoPathAntiga = widget.cliente?.fotoPath;
  }

  // --- FUNÇÃO DO CEP ---
  Future<void> _buscarCep() async {
    final cep = _cepController.text.trim();
    if (cep.isEmpty) return;
    setState(() => _isBuscandoCep = true);

    try {
      final dados = await _viaCepService.buscarCep(cep);
      if (dados != null) {
        _enderecoController.text = dados['logradouro'] ?? '';
        _bairroController.text = dados['bairro'] ?? '';
        setState(() {});

        // CORREÇÃO AQUI: FocusScope dentro do if (mounted)
        if (mounted) {
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Endereço encontrado!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isBuscandoCep = false);
    }
  }

  // --- FUNÇÃO DA FOTO (RECURSO NATIVO) ---
  Future<void> _tirarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera, // Abre a câmera do celular
        imageQuality: 50, // Reduz a qualidade para não pesar
      );

      if (foto != null) {
        setState(() {
          _fotoSelecionada = File(foto.path);
        });
      }
    } catch (e) {
      // TRATAMENTO DE PERMISSÃO NEGADA (Critério 10)
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Câmera Indisponível'),
            content: const Text('Não foi possível acessar a câmera. Você pode continuar o cadastro sem foto ou liberar o acesso nas configurações do celular.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Salvar sem foto')
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Aqui poderia abrir as configurações do Android no futuro
                  },
                  child: const Text('Abrir Configurações')
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<ClientesViewModel>();
    final novoCliente = Cliente(
      id: widget.cliente?.id,
      ownerId: '',
      nome: _nomeController.text.trim(),
      telefone: _telefoneController.text.trim(),
      email: _emailController.text.trim(),
      endereco: _enderecoController.text.trim(),
      bairro: _bairroController.text.trim(),
      cep: _cepController.text.trim(),
      fotoPath: _fotoSelecionada?.path ?? _fotoPathAntiga, // Salva o caminho da foto
    );

    final sucesso = await viewModel.salvarCliente(novoCliente);

    if (mounted) {
      if (sucesso) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar cliente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cliente == null ? 'Novo Cliente' : 'Editar Cliente'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // --- INÍCIO DA ÁREA DA FOTO ---
              GestureDetector(
                onTap: _tirarFoto,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.purple.shade100,
                  backgroundImage: _fotoSelecionada != null
                      ? FileImage(_fotoSelecionada!)
                      : (_fotoPathAntiga != null ? FileImage(File(_fotoPathAntiga!)) : null),
                  child: _fotoSelecionada == null && _fotoPathAntiga == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.purple)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Toque na foto para usar a câmera', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 24),
              // --- FIM DA ÁREA DA FOTO ---

              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone (WhatsApp)', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cepController,
                      decoration: const InputDecoration(labelText: 'CEP (apenas números)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isBuscandoCep ? null : _buscarCep,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                      child: _isBuscandoCep
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.search),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço (Rua, Nº)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(labelText: 'Bairro', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                  child: const Text('Salvar Cliente', style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}