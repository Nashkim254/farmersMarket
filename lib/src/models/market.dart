import 'package:farmersmarket/src/models/location.dart';

class Market {
  final String title;
  final String dateBegin;
  final String dateEnd;
  final Location location;
  final bool acceptingOrders;
  final String marketId;

  Market(
      {required this.title,
      required this.dateBegin,
      required this.dateEnd,
      required this.location,
      required this.marketId,
      this.acceptingOrders = false});

  Market.fromFirestore(Map<String, dynamic> firestore)
      : title = firestore['title'],
        dateBegin = firestore['dateBegin'],
        dateEnd = firestore['dateEnd'],
        location = Location.fromFirestore(firestore['location']),
        marketId = firestore['marketId'],
        acceptingOrders = firestore['acceptingOrders'];
}
