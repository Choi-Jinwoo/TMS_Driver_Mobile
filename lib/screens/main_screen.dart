import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:huen_delivery_mobile/components/delivery/delivery_view.dart';
import 'package:huen_delivery_mobile/models/Delivery.dart';
import 'package:huen_delivery_mobile/notifiers/deliveries_notifier.dart';
import 'package:huen_delivery_mobile/third_party/google_third_party.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Marker> _markers = [];
  GoogleMapController _mapController;

  @override
  void initState() {
    DeliveriesNotifier deliveriesNotifier =
        Provider.of<DeliveriesNotifier>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      deliveriesNotifier.fetchDeliveries();
    });

    super.initState();
  }

  _initMarkers(List<Delivery> deliveries) {
    _markers.clear();
    for (Delivery delivery in deliveries) {
      Marker marker = Marker(
        markerId: MarkerId(delivery.id.toString()),
        position: delivery.addressPoint,
        infoWindow: InfoWindow(
          title: delivery.productName,
          snippet: delivery.address,
        ),
      );

      setState(() {
        _markers.add(marker);
      });
    }
  }

  _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  _moveCamera(LatLng point) {
    _mapController.moveCamera(CameraUpdate.newLatLng(point));
  }

  @override
  Widget build(BuildContext context) {
    DeliveriesNotifier deliveriesNotifier =
        Provider.of<DeliveriesNotifier>(context);

    Size deviceSize = MediaQuery.of(context).size;
    List<Delivery> deliveries = deliveriesNotifier.getDeliveries();

    _initMarkers(deliveries);

    return Scaffold(
      body: deliveriesNotifier == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  height: deviceSize.height * 0.6,
                  child: GoogleMap(
                    markers: _markers.toSet(),
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(37.576183893224865, 126.97665492505988),
                      zoom: 10.0,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: deliveries.length,
                    itemBuilder: (BuildContext context, int index) =>
                        DeliveryView(
                            delivery: deliveries[index],
                            moveCamera: _moveCamera,
                        ),
                  ),
                ),
              ],
            ),
    );
  }
}
