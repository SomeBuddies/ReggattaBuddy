import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:regatta_buddy/extensions/string_extension.dart';
import 'package:regatta_buddy/providers/race_events.dart';

import 'package:regatta_buddy/utils/constants.dart' as constants;
import 'package:regatta_buddy/utils/external_api_constants.dart'
    as api_constants;
import 'package:regatta_buddy/utils/logging/logger_helper.dart';

class RaceMap extends StatelessWidget {
  final MapController mapController;
  final String eventId;

  const RaceMap(
      {super.key, required this.mapController, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: constants.startingPosition,
        zoom: constants.startingZoom,
      ),
      nonRotatedChildren: const [
        SimpleAttributionWidget(
          source: Text(constants.attributionText),
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: api_constants.tileLayerUrl,
          userAgentPackageName: api_constants.tileLayerUserAgent,
        ),
        CurrentLocationLayer(),
        RaceMarkerLayer(eventId: eventId)
      ],
    );
  }
}

class RaceMarkerLayer extends ConsumerWidget {
  const RaceMarkerLayer({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, LatLng> teamPositions =
        ref.watch(teamPositionProvider(eventId));
    var logger = getLogger("RaceMarkerLayer");
    logger.i("building a RaceMarkerLayer widget");

    return MarkerLayer(
      markers: [
        for (final team in teamPositions.keys)
          Marker(
            width: 40.0,
            height: 40.0,
            point: teamPositions[team] == null
                ? constants.startingPosition
                : teamPositions[team]!,
            builder: (ctx) => IconButton(
              icon: const Icon(
                Icons.sailing,
                shadows: [
                  Shadow(
                    blurRadius: 15.0,
                    color: Colors.black,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
              color: team.toSeededColor(),
              iconSize: 40.0,
              onPressed: () {
                logger.i("pressed on $team");
              },
            ),
          ),
      ],
    );
  }
}
