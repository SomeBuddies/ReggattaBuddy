import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'package:regatta_buddy/models/event.dart';
import 'package:regatta_buddy/widgets/icon_with_text.dart';
import 'package:regatta_buddy/widgets/route_preview_map.dart';

// This is the syntax without generator - I didn't want any generated files
// inside of the widgets folder, might move it out later.
final _placemarkProvider =
    FutureProvider.autoDispose.family<List<Placemark>, LatLng>((ref, location) async {
  return placemarkFromCoordinates(
    location.latitude,
    location.longitude,
  );
});

class EventDetailsItem extends ConsumerWidget {
  final Event event;

  const EventDetailsItem(
    this.event, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placemark = ref.watch(_placemarkProvider(event.location));

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.all(15.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: RoutePreviewMap(event.route),
            ),
            const SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  event.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  event.description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconWithText(
                  icon: const Icon(Icons.calendar_month),
                  label: DateFormat("dd.MM.yyyy").format(event.date),
                ),
                IconWithText(
                  icon: const Icon(Icons.access_time),
                  label: DateFormat("HH:mm").format(event.date),
                ),
                placemark.when(
                  data: (data) => IconWithText(
                    icon: const Icon(Icons.pin_drop),
                    label: data.first.locality ?? event.location.toString(),
                  ),
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
