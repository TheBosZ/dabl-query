library query_test;

import 'package:unittest/unittest.dart';
import '../lib/query.dart';

main() {
	Query q = new Query('awesome');
	q.add('Nathan', '\'Is cool');
	q.prettyPrint = false;
	test('Basic query ', (){
		expect(q.toString(), equalsIgnoringCase("select awesome.* from awesome where Nathan = ''Is cool'"));
	});
}