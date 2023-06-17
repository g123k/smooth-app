import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/generic_lib/design_constants.dart' hide EMPTY_WIDGET;
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:visibility_detector/visibility_detector.dart';

class KnowledgePanelWorldMapCard extends StatefulWidget {
  const KnowledgePanelWorldMapCard(this.mapElement);

  final KnowledgePanelWorldMapElement mapElement;

  @override
  State<KnowledgePanelWorldMapCard> createState() =>
      _KnowledgePanelWorldMapCardState();
}

class _KnowledgePanelWorldMapCardState extends State<KnowledgePanelWorldMapCard>
    with AutomaticKeepAliveClientMixin {
  final Key _visibilityDetectorKey = const Key('KnowledgePanelWorldMapCard');
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    print('here init');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('did change');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.mapElement.pointers.isEmpty ||
        widget.mapElement.pointers.first.geo == null) {
      return EMPTY_WIDGET;
    }

    // TODO(monsieurtanuki): Zoom the map to show all [mapElement.pointers]
    return VisibilityDetector(
      key: _visibilityDetectorKey,
      onVisibilityChanged: (VisibilityInfo info) {
        print(info);
        if (!_visible && info.visible) {
          setState(() => _visible = true);
        }
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: MEDIUM_SPACE),
        child: SizedBox(
          height: 200,
          child: EMPTY_WIDGET,
        ),
      ),
    );
  }

  FlutterMap _buildFlutterMap() {
    print('flutter map');
    return FlutterMap(
      options: MapOptions(
        // The first pointer is used as the center of the map.
        center: LatLng(
          widget.mapElement.pointers.first.geo!.lat,
          widget.mapElement.pointers.first.geo!.lng,
        ),
        zoom: 6.0,
      ),
      layers: <LayerOptions>[
        TileLayerOptions(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayerOptions(
          markers: getMarkers(widget.mapElement.pointers),
        ),
      ],
      nonRotatedChildren: <Widget>[
        AttributionWidget(
          attributionBuilder: (BuildContext context) {
            return Align(
              alignment: Alignment.bottomRight,
              child: ColoredBox(
                color: const Color(0xCCFFFFFF),
                child: GestureDetector(
                  onTap: () => LaunchUrlHelper.launchURL(
                    'https://www.openstreetmap.org/copyright',
                    false,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '© OpenStreetMap contributors',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.blue,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  List<Marker> getMarkers(List<KnowledgePanelGeoPointer> pointers) {
    final List<Marker> markers = <Marker>[];
    for (final KnowledgePanelGeoPointer pointer in pointers) {
      if (pointer.geo == null) {
        continue;
      }
      markers.add(
        Marker(
          point: LatLng(pointer.geo!.lat, pointer.geo!.lng),
          builder: (BuildContext ctx) => const Icon(
            Icons.pin_drop,
            color: Colors.lightBlue,
          ),
        ),
      );
    }
    return markers;
  }

  @override
  bool get wantKeepAlive => true;
}
