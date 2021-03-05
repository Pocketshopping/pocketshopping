import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

@immutable
class CurrentPathLine {
  final GeoPoint source;
  final GeoPoint destination;
  final bool hasVisitedSource;
  final bool hasVisitedDestination;
  final String id;

  CurrentPathLine({
    this.source,
    this.destination,
    this.hasVisitedSource,
    this.hasVisitedDestination,
    this.id,
  });

  CurrentPathLine copyWith({
    GeoPoint source,
    GeoPoint destination,
    bool hasVisitedSource,
    bool hasVisitedDestination,
    String id
  }) {
    return CurrentPathLine(
      source: source ?? this.source,
      destination: destination ?? this.destination,
      hasVisitedSource: hasVisitedSource ?? this.hasVisitedSource,
      hasVisitedDestination: hasVisitedDestination ?? this.hasVisitedDestination,
      id: id ?? this.id
    );
  }

  @override
  int get hashCode =>
      source.hashCode ^
      destination.hashCode ^
      hasVisitedSource.hashCode ^
      hasVisitedDestination.hashCode ^
      id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CurrentPathLine &&
              runtimeType == other.runtimeType &&
              source == other.source &&
              destination == other.destination &&
              hasVisitedSource == other.hasVisitedSource &&
              hasVisitedDestination == other.hasVisitedDestination &&
              id == other.id;

  @override
  String toString() {
    return '''Instance of CurrentPathLine''';
  }

  Future<CurrentPathLine> proximityCheck(Position current)async{
    if(!hasVisitedSource){
      double sourceDistance = distanceBetween(current.latitude, current.longitude, source.latitude, source.longitude);
      if(sourceDistance <= 100){
        return visitedSource();
      }
      else
        return null;
    }
    else{
      double destinationDistance = distanceBetween(current.latitude, current.longitude, destination.latitude, destination.longitude);
      if(destinationDistance <= 100){
        return visitedDestination();
      }
      else
        return null;
    }
  }

  CurrentPathLine visitedSource() {
    return  CurrentPathLine(
      destination: destination??null,
      hasVisitedSource: true,
      source: source??null,
        hasVisitedDestination:hasVisitedDestination??false,
       id:id??''
    );
  }

  CurrentPathLine visitedDestination() {
    return  CurrentPathLine(
        destination: destination??null,
        hasVisitedSource: true,
        source: source??null,
        hasVisitedDestination:true,
        id:id??''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'destination': destination??null,
      'hasVisitedSource': hasVisitedSource??false,
      'source': source??null,
      'hasVisitedDestination':hasVisitedDestination??false,
      'id':id??''
    };
  }

  static CurrentPathLine fromSnap(DocumentSnapshot cpl) {
    return CurrentPathLine(
        destination: cpl.data()['destination'],
        hasVisitedSource: cpl.data()['hasVisitedSource'],
        hasVisitedDestination: cpl.data()['hasVisitedDestination'],
        source: cpl.data()['source'],
        id: cpl.id,

    );
  }
}
