// import 'dart:typed_data';
// import 'package:test/test.dart';
// import 'password_manager_server/utils/hash_parser.dart';
//
// void main() {
//   group('parseUint8ListFromDb', () {
//     test('parses binary Uint8List', () {
//       final input = Uint8List.fromList([1, 2, 3, 4]);
//       final result = parseUint8ListFromDb(input, 'test');
//       expect(result, equals(input));
//     });
//
//     test('parses object format string {1,2,3}', () {
//       final input = '{1, 2, 3}';
//       final result = parseUint8ListFromDb(input, 'test');
//       expect(result, equals(Uint8List.fromList([1, 2, 3])));
//     });
//
//     test('parses JSON array string "[4,5,6]"', () {
//       final input = '[4,5,6]';
//       final result = parseUint8ListFromDb(input, 'test');
//       expect(result, equals(Uint8List.fromList([4, 5, 6])));
//     });
//
//     test('parses base64 string', () {
//       final base64 = 'AQIDBA=='; // [1,2,3,4]
//       final result = parseUint8ListFromDb(base64, 'test');
//       expect(result, equals(Uint8List.fromList([1, 2, 3, 4])));
//     });
//
//     test('returns null for invalid string', () {
//       final input = 'not a valid base64 or object';
//       final result = parseUint8ListFromDb(input, 'test');
//       expect(result, isNull);
//     });
//
//     test('parses List<int>', () {
//       final input = [10, 20, 30];
//       final result = parseUint8ListFromDb(input, 'test');
//       expect(result, equals(Uint8List.fromList([10, 20, 30])));
//     });
//
//     test('handles malformed object format', () {
//       final input = '{1,abc,3}';
//       final result = parseUint8ListFromDb(input, 'test');
//       expect(result, isNull);
//     });
//   });
//
//   group('parseObjectFormat', () {
//     test('parses valid object string', () {
//       final input = '{100,200,255}';
//       final result = parseObjectFormat(input, 'test');
//       expect(result, equals(Uint8List.fromList([100, 200, 255])));
//     });
//
//     test('returns null on value > 255', () {
//       final input = '{300}';
//       final result = parseObjectFormat(input, 'test');
//       expect(result, isNull);
//     });
//
//     test('returns null on non-numeric', () {
//       final input = '{one,two}';
//       final result = parseObjectFormat(input, 'test');
//       expect(result, isNull);
//     });
//
//     test('returns empty list on empty braces', () {
//       final input = '{}';
//       final result = parseObjectFormat(input, 'test');
//       expect(result, equals(Uint8List(0)));
//     });
//   });
// }
