import 'package:agro_guardian/l10n/locale_controller.dart';
import 'package:flutter/widgets.dart';

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    final controller = scope?.notifier;
    if (controller == null) {
      throw FlutterError(
        'LocaleScope.of() called with a context that does not contain a LocaleScope.',
      );
    }
    return controller;
  }
}
