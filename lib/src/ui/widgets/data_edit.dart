import 'package:flutter/material.dart';

class DatePickerField extends StatefulWidget {
  final String label;
  final String hint;
  final DateTime? dataInicial;
  final DateTime? primeiraData;
  final DateTime? ultimaData;
  final ValueChanged<DateTime>? onDataSelecionada;
  final String? Function(String?)? validator;
  final TextEditingController dataController;

  const DatePickerField({
    super.key,
    required this.dataController,
    this.label = 'Data',
    this.hint = 'DD/MM/AAAA',
    this.dataInicial,
    this.primeiraData,
    this.ultimaData,
    this.onDataSelecionada,
    this.validator,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? _dataSelecionada;

  @override
  void initState() {
    super.initState();
    if (widget.dataInicial != null) {
      _dataSelecionada = widget.dataInicial;
      widget.dataController.text = _formatarData(widget.dataInicial!);
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  Future<void> _selecionarData() async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: widget.primeiraData ?? DateTime(2000),
      lastDate: widget.ultimaData ?? DateTime(2100),
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataSelecionada = dataEscolhida;
        widget.dataController.text = _formatarData(dataEscolhida);
      });
      widget.onDataSelecionada?.call(dataEscolhida);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.dataController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
      validator: widget.validator,
      onTap: _selecionarData,
    );
  }
}
