import 'package:flutter/widgets.dart';

class psProvider extends StatefulWidget {
  const psProvider({this.data, this.child});

  final data;
  final child;

  @override
  Widget build(BuildContext context) {
    return new _InheritedProvider(data: data, child: child);
  }

  static of(BuildContext context) {
    _InheritedProvider p =
        context.dependOnInheritedWidgetOfExactType(aspect: _InheritedProvider);
    return p.data;
  }

  @override
  State<StatefulWidget> createState() => new _ProviderState();
}

class _ProviderState extends State<psProvider> {
  @override
  initState() {
    super.initState();
    widget.data.addListener(didValueChange);
  }

  didValueChange() => setState(() {});

  @override
  dispose() {
    widget.data.removeListener(didValueChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedProvider(
      data: widget.data,
      child: widget.child,
    );
  }
}

class _InheritedProvider extends InheritedWidget {
  _InheritedProvider({this.data, this.child})
      : _dataValue = data.value,
        super(child: child);
  final data;
  final child;
  final _dataValue;

  @override
  bool updateShouldNotify(_InheritedProvider oldWidget) {
    return _dataValue != oldWidget._dataValue;
  }
}
