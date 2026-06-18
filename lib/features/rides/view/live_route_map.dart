import 'dart:math';
import 'package:flutter/material.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';

/// A single geographic point. Swap this out for whatever your backend
/// engineer gives you (e.g. a `LatLng` from google_maps_flutter, or a
/// custom model from your sockets/Firebase stream). Keeping it this
/// simple means nothing else in this widget needs to change later —
/// you'd just feed real numbers into [origin], [destination], and
/// [driverPosition] instead of the mock defaults.
class RoutePoint {
  final String label;
  final double lat;
  final double lng;

  const RoutePoint({required this.label, required this.lat, required this.lng});
}

/// Stylized "Live Route" card matching the TravelMate Figma design.
///
/// This is intentionally NOT a real map (no tiles, no SDK) so it has
/// zero extra dependencies right now. It's built so a real map can be
/// dropped in later without touching any calling code:
///
///   - All geographic data comes in as props ([origin], [destination],
///     [driverPosition]) rather than being hardcoded.
///   - [driverProgress] (0.0 -> 1.0) drives where the car icon sits
///     along the route — your backend engineer just needs to send you
///     a single progress value (or you compute it from coordinates).
///   - The whole illustrated area is isolated in [_RouteCanvas]. To go
///     real later: replace [_RouteCanvas] with a GoogleMap/FlutterMap
///     widget and keep the header/footer chrome around it as-is.
class LiveRouteMap extends StatelessWidget {
  final RoutePoint origin;
  final RoutePoint destination;

  /// 0.0 = at origin, 1.0 = at destination. Drives the car icon position
  /// along the route. Defaults to a mock mid-route value.
  final double driverProgress;

  final VoidCallback? onExpand;

  const LiveRouteMap({
    super.key,
    this.origin = const RoutePoint(
      label: 'Ikeja, Lagos',
      lat: 6.6018,
      lng: 3.3515,
    ),
    this.destination = const RoutePoint(
      label: 'Utako, Abuja',
      lat: 9.0765,
      lng: 7.4951,
    ),
    this.driverProgress = 0.42,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Live Route',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kPrimaryBlue,
                decoration: TextDecoration.underline,
              ),
            ),
            const Spacer(),
            if (onExpand != null)
              InkWell(
                onTap: onExpand,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.fullscreen,
                    size: 18,
                    color: Colors.black45,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: _RouteCanvas(
              originLabel: origin.label,
              destinationLabel: destination.label,
              progress: driverProgress.clamp(0.0, 1.0),
            ),
          ),
        ),
      ],
    );
  }
}

/// Isolated illustrated map surface. Swap this whole widget out for a
/// real map later — everything it needs comes in as constructor params.
class _RouteCanvas extends StatelessWidget {
  final String originLabel;
  final String destinationLabel;
  final double progress;

  const _RouteCanvas({
    required this.originLabel,
    required this.destinationLabel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base "map" surface
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFF3F1), Color(0xFFE6ECE9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Decorative road network + route, drawn with CustomPaint
        CustomPaint(painter: _MapPainter(progress: progress)),
        // Origin pin
        Align(
          alignment: const Alignment(-0.72, -0.68),
          child: _Pin(
            label: originLabel,
            color: kPrimaryGreen,
            icon: Icons.location_on,
          ),
        ),
        // Destination pin
        Align(
          alignment: const Alignment(0.74, 0.7),
          child: _Pin(
            label: destinationLabel,
            color: kErrorRed,
            icon: Icons.location_on,
          ),
        ),
        // Live badge
        const Positioned(top: 10, left: 10, child: _LiveBadge()),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  final double progress;
  _MapPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final routeStart = Offset(size.width * 0.16, size.height * 0.22);
    final routeEnd = Offset(size.width * 0.86, size.height * 0.86);

    // Faint background streets for map texture
    final streetPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (final f in [0.18, 0.4, 0.62, 0.84]) {
      canvas.drawLine(
        Offset(0, size.height * f),
        Offset(size.width, size.height * f * 0.9),
        streetPaint,
      );
    }
    for (final f in [0.2, 0.45, 0.7]) {
      canvas.drawLine(
        Offset(size.width * f, 0),
        Offset(size.width * f * 0.85, size.height),
        streetPaint,
      );
    }

    // Route path: a gentle curve from origin to destination
    final routePath = Path()
      ..moveTo(routeStart.dx, routeStart.dy)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.42,
        routeEnd.dx,
        routeEnd.dy,
      );

    final routePaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(routePath, routePaint);

    // Car position along the path at `progress`
    final metrics = routePath.computeMetrics().first;
    final carPos = metrics.getTangentForOffset(metrics.length * progress);
    if (carPos != null) {
      _drawCar(canvas, carPos.position, carPos.angle);
    }
  }

  void _drawCar(Canvas canvas, Offset center, double angle) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final bodyPaint = Paint()..color = const Color(0xFF6C63FF);
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-13, -7, 26, 14),
      const Radius.circular(5),
    );
    canvas.drawShadow(Path()..addRRect(rect), Colors.black, 3, true);
    canvas.drawRRect(rect, bodyPaint);

    final windowPaint = Paint()..color = Colors.white.withOpacity(0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, -5, 10, 6),
        const Radius.circular(2),
      ),
      windowPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Pin extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Pin({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
