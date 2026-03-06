import 'package:flutter/material.dart';
import 'package:mirly/examples/bicycle_page.dart';
import 'package:mirly/examples/circle_map_object_page.dart';
import 'package:mirly/examples/clusterized_placemark_collection_page.dart';
import 'package:mirly/examples/driving_page.dart';
import 'package:mirly/examples/map_controls_page.dart';
import 'package:mirly/examples/map_object_collection_page.dart';
import 'package:mirly/examples/placemark_map_object_page.dart';
import 'package:mirly/examples/polygon_map_object_page.dart';
import 'package:mirly/examples/polyline_map_object_page.dart';
import 'package:mirly/examples/reverse_search_page.dart';
import 'package:mirly/examples/search_page.dart';
import 'package:mirly/examples/suggest_page.dart';
import 'package:mirly/examples/user_layer_page.dart';
import 'package:mirly/examples/widgets/map_page.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

void main() {
  AndroidYandexMap.useAndroidViewSurface = false;
  runApp(const MaterialApp(home: MainPage()));
}

const List<MapPage> _allPages = <MapPage>[
  MapControlsPage(),
  ClusterizedPlacemarkCollectionPage(),
  MapObjectCollectionPage(),
  PlacemarkMapObjectPage(),
  PolylineMapObjectPage(),
  PolygonMapObjectPage(),
  CircleMapObjectPage(),
  UserLayerPage(),
  SuggestionsPage(),
  SearchPage(),
  ReverseSearchPage(),
  BicyclePage(),
  DrivingPage(),
];

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  void _pushPage(BuildContext context, MapPage page) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(page.title)),
          body: Container(padding: const EdgeInsets.all(8), child: page),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YandexMap examples')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: YandexMap(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allPages.length,
              itemBuilder: (_, int index) => ListTile(
                title: Text(_allPages[index].title),
                onTap: (() => _pushPage(context, _allPages[index])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
