import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;

class OSMMap extends StatelessWidget {
  final latlong2.LatLng center;
  final List<latlong2.LatLng>? markers;

  const OSMMap({super.key, required this.center, this.markers});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(center: center, zoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.ecotrack',
        ),
        if (markers != null)
          MarkerLayer(
            markers: markers!
                .map((point) => Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, size: 40),
                    ))
                .toList(),
          ),
      ],
    );
  }
}
