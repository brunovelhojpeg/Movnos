import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:supabase_flutter/supabase_flutter.dart';

/// MAPA DEV (OpenStreetMap) — SEM Google Maps
/// - mapa full screen
/// - tracking (geolocator)
/// - salva em public.workouts (route_points jsonb)
class MapRecordPage extends StatefulWidget {
  final bool showClose;
  const MapRecordPage({super.key, this.showClose = true});

  @override
  State<MapRecordPage> createState() => _MapRecordPageState();
}

class _ActivityTypeLite {
  final String id;
  final String displayName;
  const _ActivityTypeLite({required this.id, required this.displayName});
}

class _MapRecordPageState extends State<MapRecordPage> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _sub;

  // tipos
  bool _loadingTypes = true;
  List<_ActivityTypeLite> _types = const [];
  _ActivityTypeLite? _selectedType;

  // gravação
  bool _recording = false;
  bool _saving = false;
  DateTime? _startedAtUtc;
  DateTime? _endedAtUtc;

  double _distanceMeters = 0;
  Position? _lastPos;
  final List<_RoutePoint> _points = [];

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    setState(() => _loadingTypes = true);
    try {
      final rows = await _supabase
          .from('activity_types')
          .select('id, display_name')
          .eq('is_enabled', true)
          .order('sort_order')
          .order('display_name');

      final list = (rows as List)
          .map(
            (e) => _ActivityTypeLite(
              id: e['id'] as String,
              displayName: e['display_name'] as String,
            ),
          )
          .toList(growable: false);

      _types = list;
      _selectedType = list.isNotEmpty ? list.first : null;
    } catch (e) {
      _toast('Erro ao carregar tipos: $e');
    } finally {
      if (mounted) setState(() => _loadingTypes = false);
    }
  }

  Future<void> _pickType() async {
    if (_loadingTypes) return;
    if (_types.isEmpty) {
      _toast('Nenhum tipo cadastrado.');
      return;
    }

    final picked = await showModalBottomSheet<_ActivityTypeLite>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView.separated(
            itemCount: _types.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final t = _types[i];
              final selected = _selectedType?.id == t.id;
              return ListTile(
                title: Text(t.displayName),
                trailing: selected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(t),
              );
            },
          ),
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedType = picked);
    }
  }

  Future<void> _ensurePermissions() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Localização desativada. Ative o GPS.');
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão negada permanentemente. Ative nas configurações.',
      );
    }
  }

  Future<void> _start() async {
    if (_selectedType == null) {
      _toast('Selecione um tipo de treino.');
      return;
    }
    await _ensurePermissions();

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _points
      ..clear()
      ..add(_RoutePoint.fromPosition(pos));

    _distanceMeters = 0;
    _lastPos = pos;
    _startedAtUtc = DateTime.now().toUtc();
    _endedAtUtc = null;
    _recording = true;

    _sub?.cancel();
    _sub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((p) {
          if (!_recording) return;

          if (_lastPos != null) {
            final d = Geolocator.distanceBetween(
              _lastPos!.latitude,
              _lastPos!.longitude,
              p.latitude,
              p.longitude,
            );
            // filtro contra saltos
            if (d > 0 && d < 200) {
              _distanceMeters += d;
            }
          }

          _lastPos = p;
          _points.add(_RoutePoint.fromPosition(p));

          _mapController.move(
            ll.LatLng(p.latitude, p.longitude),
            _mapController.camera.zoom,
          );

          if (mounted) setState(() {});
        });

    _mapController.move(ll.LatLng(pos.latitude, pos.longitude), 16);
    if (mounted) setState(() {});
  }

  Future<void> _stop() async {
    _recording = false;
    _endedAtUtc = DateTime.now().toUtc();
    await _sub?.cancel();
    _sub = null;
    if (mounted) setState(() {});
  }

  Future<void> _toggleRecord() async {
    if (_saving) return;
    try {
      if (_recording) {
        await _stop();
      } else {
        await _start();
      }
    } catch (e) {
      _toast('$e');
    }
  }

  int get _durationSeconds {
    final s = _startedAtUtc;
    final e = _endedAtUtc ?? (_recording ? DateTime.now().toUtc() : null);
    if (s == null || e == null) return 0;
    return e.difference(s).inSeconds;
  }

  double get _paceSecPerKm {
    final km = _distanceMeters / 1000.0;
    if (km <= 0) return 0;
    return _durationSeconds / km;
  }

  String _formatTime(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatKm(double meters) => (meters / 1000).toStringAsFixed(2);

  String _formatPace(double paceSecPerKm) {
    if (paceSecPerKm <= 0) return '--:--';
    final total = paceSecPerKm.round();
    final m = total ~/ 60;
    final s = total % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _saveWorkout() async {
    if (_saving) return;
    if (_startedAtUtc == null) return;
    if (_endedAtUtc == null) await _stop();
    if (_endedAtUtc == null) return;

    final user = _supabase.auth.currentUser;
    if (user == null) {
      _toast('Você precisa estar logado.');
      return;
    }
    if (_selectedType == null) {
      _toast('Selecione um tipo de treino.');
      return;
    }

    setState(() => _saving = true);
    try {
      final payload = {
        'user_id': user.id,
        'activity_type_id': _selectedType!.id,
        'started_at': _startedAtUtc!.toIso8601String(),
        'ended_at': _endedAtUtc!.toIso8601String(),
        'duration_seconds': _durationSeconds,
        'distance_meters': _distanceMeters,
        'route_points': _points.map((e) => e.toJson()).toList(),
      };
      await _supabase.from('workouts').insert(payload);
      if (!mounted) return;
      _toast('Treino salvo!');
      Navigator.of(context).pop(true);
    } catch (e) {
      _toast('Falha ao salvar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final latlngs = _points
        .map((p) => ll.LatLng(p.lat, p.lng))
        .toList(growable: false);
    final title =
        _selectedType?.displayName ??
        (_loadingTypes ? 'Carregando...' : 'Selecione');
    final timeStr = _formatTime(_durationSeconds);
    final paceStr = _formatPace(_paceSecPerKm);
    final distStr = _formatKm(_distanceMeters);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: ll.LatLng(-23.5505, -46.6333),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.movnos.app',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              if (latlngs.length >= 2)
                PolylineLayer(
                  polylines: [Polyline(points: latlngs, strokeWidth: 6)],
                ),
              if (latlngs.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latlngs.last,
                      width: 44,
                      height: 44,
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
            ],
          ),

          if (widget.showClose)
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

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              child: _BottomStatsCard(
                height: 150,
                title: title,
                time: timeStr,
                pace: paceStr,
                distanceKm: distStr,
              ),
            ),
          ),

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
                    _PillButton(
                      icon: Icons.directions_run,
                      label: title,
                      onTap: _pickType,
                    ),
                    _MainRecordButton(
                      recording: _recording,
                      saving: _saving,
                      onTap: _toggleRecord,
                    ),
                    _PillButton(
                      icon: Icons.check_circle,
                      label: 'Salvar',
                      onTap: _saving ? () {} : _saveWorkout,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomStatsCard extends StatelessWidget {
  final String title;
  final String time;
  final String pace;
  final String distanceKm;
  final double height;

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
        color: Colors.white.withOpacity(0.95),
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
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
  final bool recording;
  final bool saving;
  final VoidCallback onTap;
  const _MainRecordButton({
    required this.recording,
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
        decoration: const BoxDecoration(
          color: Colors.deepOrange,
          shape: BoxShape.circle,
          boxShadow: [
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
              : Icon(
                  recording ? Icons.stop : Icons.play_arrow,
                  size: 36,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
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

class _RoutePoint {
  final double lat;
  final double lng;
  final String t;

  const _RoutePoint({required this.lat, required this.lng, required this.t});

  factory _RoutePoint.fromPosition(Position p) {
    return _RoutePoint(
      lat: p.latitude,
      lng: p.longitude,
      t: DateTime.now().toUtc().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng, 't': t};
}
