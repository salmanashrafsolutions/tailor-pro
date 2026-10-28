import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_pro/core/utils/fraction_formatter.dart';

void main() {
  group('FractionFormatter Tests', () {
    test('formats whole numbers cleanly without trailing .0', () {
      expect(FractionFormatter.format(40.0), '40');
      expect(FractionFormatter.format(15.0), '15');
      expect(FractionFormatter.format(0.0), '0');
    });

    test('formats common tailor fractions accurately', () {
      expect(FractionFormatter.format(38.5), '38½');
      expect(FractionFormatter.format(17.25), '17¼');
      expect(FractionFormatter.format(40.75), '40¾');
      expect(FractionFormatter.format(22.125), '22⅛');
      expect(FractionFormatter.format(22.375), '22⅜');
      expect(FractionFormatter.format(22.625), '22⅝');
      expect(FractionFormatter.format(22.875), '22⅞');
    });

    test('parses unicode fraction symbols into decimals', () {
      expect(FractionFormatter.parse('38½'), 38.5);
      expect(FractionFormatter.parse('17¼'), 17.25);
      expect(FractionFormatter.parse('40¾'), 40.75);
      expect(FractionFormatter.parse('22⅛'), 22.125);
      expect(FractionFormatter.parse('22⅜'), 22.375);
      expect(FractionFormatter.parse('22⅝'), 22.625);
      expect(FractionFormatter.parse('22⅞'), 22.875);
    });

    test('parses slash fraction formats', () {
      expect(FractionFormatter.parse('38 1/2'), 38.5);
      expect(FractionFormatter.parse('17 1/4'), 17.25);
      expect(FractionFormatter.parse('40 3/4'), 40.75);
      expect(FractionFormatter.parse('22 1/8'), 22.125);
    });

    test('parses pure fraction without whole number', () {
      expect(FractionFormatter.parse('½'), 0.5);
      expect(FractionFormatter.parse('¼'), 0.25);
      expect(FractionFormatter.parse('¾'), 0.75);
    });

    test('parses direct decimal string', () {
      expect(FractionFormatter.parse('42.5'), 42.5);
      expect(FractionFormatter.parse('36'), 36.0);
    });

    test('handles null and invalid inputs gracefully', () {
      expect(FractionFormatter.parse(null), isNull);
      expect(FractionFormatter.parse(''), isNull);
      expect(FractionFormatter.parse('abc'), isNull);
      expect(FractionFormatter.format(null), '');
    });
  });
}

