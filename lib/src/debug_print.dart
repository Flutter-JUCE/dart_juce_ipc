// ignore_for_file: public_member_api_docs

import "dart:convert";

extension DebugPrintByte on int {
  String toPadded() => toString().padLeft(3);
  String toHex() => "0x${toRadixString(16).padLeft(2, '0')}";
  String toChar() {
    if (this < 0x20 || this > 0x7E) {
      return "�";
    }
    return ascii.decode([this]);
  }
}

extension DebugPrintBytes on List<int> {
  String toHex() =>
      "[${map((e) => e.toHex()).reduce((value, element) => "$value, $element")}]";
  String toChar() =>
      map((e) => e.toChar()).reduce((value, element) => "$value$element");
}
