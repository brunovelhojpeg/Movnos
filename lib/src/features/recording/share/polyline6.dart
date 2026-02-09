class Polyline6 {
  // Encodes LatLng list to polyline with 1e6 precision (Mapbox supports polyline6)
  static String encode(List<List<double>> coords) {
    int lastLat = 0;
    int lastLng = 0;
    final StringBuffer result = StringBuffer();

    for (final c in coords) {
      final int lat = (c[0] * 1e6).round();
      final int lng = (c[1] * 1e6).round();

      _encodeValue(lat - lastLat, result);
      _encodeValue(lng - lastLng, result);

      lastLat = lat;
      lastLng = lng;
    }
    return result.toString();
  }

  static void _encodeValue(int v, StringBuffer out) {
    v = v < 0 ? ~(v << 1) : (v << 1);
    while (v >= 0x20) {
      final int charCode = (0x20 | (v & 0x1f)) + 63;
      out.writeCharCode(charCode);
      v >>= 5;
    }
    out.writeCharCode(v + 63);
  }
}
