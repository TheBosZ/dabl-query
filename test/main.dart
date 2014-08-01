library query_test;

import 'package:unittest/unittest.dart';
import 'package:dabl_query/query.dart';

main() {
	Query q = new Query('awesome');
	q.add('Nathan', '\'Is cool');
	test('Creates query', () {
		expect(q.toString(), equalsIgnoringWhitespace("SELECT awesome.* FROM awesome WHERE Nathan = ''Is cool'"));
	});
}