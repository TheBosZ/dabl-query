library query_test;

import 'package:unittest/unittest.dart';
import '../lib/query.dart';

main() {
	Query q = new Query('awesome');
	q.add('Nathan', '\'Is cool');
	print(q);
}