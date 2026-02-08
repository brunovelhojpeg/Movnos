import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'record_service.dart';

class MapRecordPage extends StatefulWidget {
  final String? activityTypeId;
  final String activityLabel;

  const MapRecordPage({
    super.key,
    required this.activityTypeId,
    required this.activityLabel,
  });

  @override
  State<MapRecordPage> createState() => _MapRecordPageState();
}

class _MapRecordPageState extends State<MapRecordPage> {
  final RecordService _service = RecordService();
  GoogleMapController? _mapController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    _service.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  // ==================== FORMATAÇÃO ====================

  String _formatTime(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatPace(double paceSecPerKm) {
    if (paceSecPerKm <= 0) return '--:--';
    final total = paceSecPerKm.round();
    final m = total ~/ 60;
    final s = total % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatKm(double meters) => (meters / 1000).toStringAsFixed(2);

  // ==================== AÇÕES ====================

  Future<void> _toggleRecord() async {
    if (_saving) return;

    try {
      final state = _service.state;

      if (state.isRecording && !state.isPaused) {
        // Pausar
        _service.pause();
      } else if (state.isRecording && state.isPaused) {
        // Retomar
        _service.resume();
      } else {
        // Iniciar
        await _service.start();
        _centerMapOnUser();
      }
    } catch (e) {
      _toast('Erro: $e');
    }
  }

  Future<void> _stop() async {
    if (_saving) return;
    await _service.stop();
  }

  Future<void> _saveWorkout() async {
    if (_saving) return;
    if (widget.activityTypeId == null) {
      _toast('Tipo de atividade não definido');
      return;
    }

    setState(() => _saving = true);

    try {
      // Para o treino se ainda estiver gravando
      if (_service.state.isRecording) {
        await _service.stop();
      }

      // Salva no Supabase
      await _service.saveActivity(activityTypeId: widget.activityTypeId!);

      if (!mounted) return;
      _toast('Treino salvo com sucesso!');
      Navigator.of(context).pop(true);
    } catch (e) {
      _toast('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _centerMapOnUser() {
    final pos = _service.state.currentPosition;
    if (pos != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16),
      );
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final state = _service.state;
    final route = state.route;

    // Polyline da rota
    final polylines = <Polyline>{};
    if (route.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: route.map((p) => LatLng(p.lat, p.lng)).toList(),
          color: Colors.deepOrange,
          width: 6,
        ),
      );
    }

    // Marker da posição atual
    final markers = <Marker>{};
    if (state.currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(
            state.currentPosition!.latitude,
            state.currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    // Dados formatados
    final timeStr = _formatTime(state.durationSeconds);
    final paceStr = _formatPace(state.paceSecPerKm);
    final distanceKm = _formatKm(state.distanceMeters);

    // Ícone do botão principal
    IconData mainIcon;
    if (state.isRecording && !state.isPaused) {
      mainIcon = Icons.pause;
    } else if (state.isPaused) {
      mainIcon = Icons.play_arrow;
    } else {
      mainIcon = Icons.play_arrow;
    }

    return Scaffold(
      body: Stack(
        children: [
          // ==================== GOOGLE MAP ====================
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-23.5505, -46.6333), // São Paulo
              zoom: 13,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _centerMapOnUser();
            },
            polylines: polylines,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // ==================== BOTÃO FECHAR ====================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topLeft,
                child: _RoundIconButton(
                  icon: Icons.close,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ),

          // ==================== CARD DE ESTATÍSTICAS ====================
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              child: _BottomStatsCard(
                height: 150,
                title: widget.activityLabel,
                time: timeStr,
                pace: paceStr,
                distanceKm: distanceKm,
              ),
            ),
          ),

          // ==================== CONTROLES INFERIORES ====================
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                height: 120,
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botão tipo de atividade
                    _PillButton(
                      icon: Icons.directions_run,
                      label: widget.activityLabel,
                      onTap: () {},
                    ),

                    // Botão principal (Play/Pause)
                    _MainRecordButton(
                      icon: mainIcon,
                      saving: _saving,
                      onTap: _toggleRecord,
                    ),

                    // Botão Stop
                    _PillButton(
                      icon: Icons.stop,
                      label: 'Parar',
                      onTap: state.isRecording ? _stop : null,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================== BOTÃO SALVAR ====================
          if (!state.isRecording && state.startedAt != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.topRight,
                  child: _RoundIconButton(
                    icon: Icons.check,
                    onTap: _saving ? null : _saveWorkout,
                    filled: true,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== WIDGETS ====================

class _BottomStatsCard extends StatelessWidget {
  final double height;
  final String title;
  final String time;
  final String pace;
  final String distanceKm;

  const _BottomStatsCard({
    required this.height,
    required this.title,
    required this.time,
    required this.pace,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x22000000),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatCell(label: 'Tempo', value: time),
              _StatCell(label: 'Ritmo (/km)', value: pace),
              _StatCell(label: 'Distância (km)', value: distanceKm),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;

  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: filled
              ? const Color.fromRGBO(255, 255, 255, 1)
              : const Color.fromRGBO(255, 255, 255, 0.9),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              blurRadius: 14,
              offset: Offset(0, 6),
              color: Color(0x22000000),
            ),
          ],
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _MainRecordButton extends StatelessWidget {
  final IconData icon;
  final bool saving;
  final VoidCallback onTap;

  const _MainRecordButton({
    required this.icon,
    required this.saving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: saving ? null : onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              blurRadius: 22,
              offset: Offset(0, 10),
              color: Color(0x33000000),
            ),
          ],
        ),
        child: Center(
          child: saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, size: 36, color: Colors.white),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: enabled
              ? const Color.fromRGBO(255, 255, 255, 0.92)
              : const Color.fromRGBO(255, 255, 255, 0.5),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              blurRadius: 14,
              offset: Offset(0, 6),
              color: Color(0x22000000),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
