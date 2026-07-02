import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';

class RoutePoint {
  final String label;
  final double lat;
  final double lng;

  const RoutePoint({required this.label, required this.lat, required this.lng});
}

class LiveRouteMap extends StatelessWidget {
  final RoutePoint origin;
  final RoutePoint destination;
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
              origin: origin,
              destination: destination,
              progress: driverProgress.clamp(0.0, 1.0),
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteCanvas extends StatefulWidget {
  final RoutePoint origin;
  final RoutePoint destination;
  final double progress;

  const _RouteCanvas({
    required this.origin,
    required this.destination,
    required this.progress,
  });

  @override
  State<_RouteCanvas> createState() => _RouteCanvasState();
}

class _RouteCanvasState extends State<_RouteCanvas> {
  bool get _canRenderMapbox {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  RoutePoint get _driverPosition {
    return RoutePoint(
      label: 'Driver',
      lat: widget.origin.lat +
          ((widget.destination.lat - widget.origin.lat) * widget.progress),
      lng: widget.origin.lng +
          ((widget.destination.lng - widget.origin.lng) * widget.progress),
    );
  }

  Point _point(RoutePoint point) {
    return Point(coordinates: Position(point.lng, point.lat));
  }

  Point _centerPoint() {
    return Point(
      coordinates: Position(
        (widget.origin.lng + widget.destination.lng) / 2,
        (widget.origin.lat + widget.destination.lat) / 2,
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    await mapboxMap.setCamera(
      CameraOptions(center: _centerPoint(), zoom: 5.3, pitch: 0),
    );

    final polylineManager =
        await mapboxMap.annotations.createPolylineAnnotationManager();
    await polylineManager.create(
      PolylineAnnotationOptions(
        geometry: LineString(
          coordinates: [
            Position(widget.origin.lng, widget.origin.lat),
            Position(_driverPosition.lng, _driverPosition.lat),
            Position(widget.destination.lng, widget.destination.lat),
          ],
        ),
        lineColor: kPrimaryBlue.toARGB32(),
        lineWidth: 4,
      ),
    );

    final circleManager =
        await mapboxMap.annotations.createCircleAnnotationManager();
    await circleManager.createMulti([
      CircleAnnotationOptions(
        geometry: _point(widget.origin),
        circleColor: kPrimaryGreen.toARGB32(),
        circleRadius: 7,
        circleStrokeColor: Colors.white.toARGB32(),
        circleStrokeWidth: 2,
      ),
      CircleAnnotationOptions(
        geometry: _point(widget.destination),
        circleColor: kErrorRed.toARGB32(),
        circleRadius: 7,
        circleStrokeColor: Colors.white.toARGB32(),
        circleStrokeWidth: 2,
      ),
      CircleAnnotationOptions(
        geometry: _point(_driverPosition),
        circleColor: const Color(0xFF6C63FF).toARGB32(),
        circleRadius: 6,
        circleStrokeColor: Colors.white.toARGB32(),
        circleStrokeWidth: 2,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!_canRenderMapbox) {
      return _MapboxUnsupportedFallback(
        originLabel: widget.origin.label,
        destinationLabel: widget.destination.label,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        MapWidget(
          styleUri: MapboxStyles.STANDARD,
          viewport: CameraViewportState(center: _centerPoint(), zoom: 5.3),
          onMapCreated: _onMapCreated,
        ),
        Align(
          alignment: const Alignment(-0.72, -0.68),
          child: _Pin(
            label: widget.origin.label,
            color: kPrimaryGreen,
            icon: Icons.location_on,
          ),
        ),
        Align(
          alignment: const Alignment(0.74, 0.7),
          child: _Pin(
            label: widget.destination.label,
            color: kErrorRed,
            icon: Icons.location_on,
          ),
        ),
        const Positioned(top: 10, left: 10, child: _LiveBadge()),
      ],
    );
  }
}

class _MapboxUnsupportedFallback extends StatelessWidget {
  final String originLabel;
  final String destinationLabel;

  const _MapboxUnsupportedFallback({
    required this.originLabel,
    required this.destinationLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: const Color(0xFFEFF3F1),
          child: const Center(
            child: Text(
              'Live map available on Android and iOS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(-0.72, -0.68),
          child: _Pin(
            label: originLabel,
            color: kPrimaryGreen,
            icon: Icons.location_on,
          ),
        ),
        Align(
          alignment: const Alignment(0.74, 0.7),
          child: _Pin(
            label: destinationLabel,
            color: kErrorRed,
            icon: Icons.location_on,
          ),
        ),
        const Positioned(top: 10, left: 10, child: _LiveBadge()),
      ],
    );
  }
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
          constraints: const BoxConstraints(maxWidth: 130),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
            color: Colors.red.withValues(alpha: 0.3),
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
