// ignore_for_file: camel_case_types, constant_identifier_names

enum FTR_SIGNAL_STATUS {
  undefined(0),
  touch_sensor(1),
  take_off(2),
  fake_source(3);

  final int value;

  static FTR_SIGNAL_STATUS? fromInt(int value) {
    try {
      return FTR_SIGNAL_STATUS.values
          .firstWhere((element) => element.value == value);
    } catch (e) {
      return null;
    }
  }

  const FTR_SIGNAL_STATUS(this.value);
}
