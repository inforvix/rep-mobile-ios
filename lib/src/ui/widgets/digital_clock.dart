import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rep_p_mobile/src/service/relogio_service.dart';
import 'package:rep_p_mobile/src/ui/fonts.dart';

class AnalogClockInforvix extends StatelessWidget {
  const AnalogClockInforvix({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CurrentTime(),
          Container(
            constraints: const BoxConstraints.expand(),
            child: CustomPaint(
              painter: ClockPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Exibe a hora DO SERVIDOR (fonte oficial do REP). Busca a hora uma vez,
/// avança o relógio localmente a cada segundo e ressincroniza com o servidor
/// a cada 60 segundos — em vez de consultar a API a cada segundo.
class CurrentTime extends StatefulWidget {
  const CurrentTime({super.key});

  @override
  State<CurrentTime> createState() => _CurrentTimeState();
}

class _CurrentTimeState extends State<CurrentTime> {
  DateTime? _horaServidor;
  bool _erro = false;

  Timer? _tickTimer;
  Timer? _resyncTimer;

  @override
  void initState() {
    super.initState();

    _sincronizar();

    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_horaServidor == null) return;
      setState(() {
        _horaServidor = _horaServidor!.add(const Duration(seconds: 1));
      });
    });

    _resyncTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _sincronizar();
    });
  }

  Future<void> _sincronizar() async {
    try {
      final hora = await RelogioService().buscarHoraAtual();
      if (!mounted) return;
      setState(() {
        _horaServidor = hora;
        _erro = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = _horaServidor == null);
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _resyncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_horaServidor == null) {
      return _erro
          ? Text(
              'Sem conexão',
              style: Fonts.textStyleBotao.copyWith(fontSize: 18),
            )
          : const CircularProgressIndicator(color: Colors.white);
    }

    return Text(
      DateFormat('HH:mm:ss').format(_horaServidor!),
      style: Fonts.textStyleBotao.copyWith(fontSize: 26),
    );
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 1;

    double radius = min(centerY, centerX);

    Paint dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    Paint secdashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    double outerRadiusDash = radius - 15;
    double innerRadiusDash = radius - 36;
    double outerRadiusSec = radius - 20;
    double innerRadiusSec = radius - 20;

    for (int i = 0; i < 60; i++) {
      if (i % 5 == 0) {
        double x1 = centerX - outerRadiusDash * cos(i * 6 * pi / 180);
        double y1 = centerX - outerRadiusDash * sin(i * 6 * pi / 180);
        double x2 = centerX - innerRadiusDash * cos(i * 6 * pi / 180);
        double y2 = centerX - innerRadiusDash * sin(i * 6 * pi / 180);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashPaint);
      } else {
        double x1 = centerX - outerRadiusSec * 0.95 * cos(i * 6 * pi / 180);
        double y1 = centerX - outerRadiusSec * 0.95 * sin(i * 6 * pi / 180);
        double x2 = centerX - innerRadiusSec * cos(i * 6 * pi / 180);
        double y2 = centerX - innerRadiusSec * sin(i * 6 * pi / 180);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), secdashPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
