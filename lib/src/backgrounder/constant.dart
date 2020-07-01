import 'dart:isolate';
import 'package:shared_preferences/shared_preferences.dart';





/// The [SharedPreferences] key to access the alarm fire count.
const String riderKey = 'rider';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'request';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences prefs;