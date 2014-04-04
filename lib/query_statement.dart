part of dabl_query;

class QueryStatement {
	/**
   * character to use as a placeholder for a quoted identifier
   */
	static final String IDENTIFIER = '[?]';

	/**
   * character to use as a placeholder for an escaped parameter
   */
	static final String PARAM = '?';

	String _query_string = '';

	List<String> _params = new List<String>();

	DDO _connection;

	List<String> _identifiers = new List<String>();

	QueryStatement([this._connection = null]);

	void setConnection(DDO conn) {
		this._connection = conn;
	}

	DDO getConnection() {
		return _connection;
	}

	void setString(String string) {
		this._query_string = string;
	}

	String getString() {
		return _query_string;
	}

	void addParams(List params) {
		this._params.addAll(params);
	}

	void setParams(List params) {
		this._params = params;
	}

	void addParam(String param) {
		_params.add(param);
	}

	List getParams() {
		return _params;
	}

	void addIdentifiers(List idents) {
		this._identifiers.addAll(idents);
	}

	void setIdentifiers(List<String> idents) {
		_identifiers = idents;
	}

	void addIdentifier(String ident) {
		_identifiers.add(ident);
	}

	List getIdentifiers() {
		return _identifiers;
	}

	String toString() {
		String string = this._query_string;
		var conn = this._connection;

		string = QueryStatement.embedIdentifiers(string, this._identifiers.toList(), conn);
		return QueryStatement.embedParams(string, this._params.toList(), conn);
	}

	static String embedIdentifiers(String string, List identifiers, [DDO conn = null]) {

		if (null != conn) {
			identifiers = conn.quoteIdentifier(identifiers).toList();
		}

		for (var x = 0; x < identifiers.length; ++x) {
			if (string.indexOf(QueryStatement.IDENTIFIER) == -1) {
				break;
			}
			string = string.replaceFirst(QueryStatement.IDENTIFIER, identifiers[x]);
		}

		if (string.indexOf(QueryStatement.IDENTIFIER) != -1) {
			throw new Exception('The number of replacements does not match the number of identifiers');
		}
		return string;
	}

	static String embedParams(String string, List params, [DDO conn = null]) {
		if (null != conn) {
			params = conn.prepareInput(params);
		} else {
			for (int x = 0; x < params.length; ++x) {
				var value = params[x];
				if (value is num) {
					continue;
				} else if (value is bool) {
					value = (value as bool) ? 1 : 0;
				} else if (null == value) {
					value = 'NULL';
				} else {
					value = "'${value}'";
				}
				params[x] = value;
			}
		}

		for (var x = 0; x < params.length; ++x) {
			string = string.replaceFirst(QueryStatement.PARAM, params[x].toString());
		}

		if (string.indexOf(QueryStatement.PARAM) != -1) {
			throw new Exception('The number of replacements does not match the number of parameters');
		}
		return string;
	}

	Future<DDOStatement> bindAndExecute() {
		DDO conn = _connection;
		String str = embedIdentifiers(getString(), _identifiers, conn);

		DDOStatement result = conn.prepare(str);
		int len = _params.length;
		int typ;
		Object value;
		for (int x = 0; x < len; ++x) {
			typ = DDO.PARAM_STR;
			value = _params[x];
			if (value is int) {
				typ = DDO.PARAM_INT;
			} else if (value == null) {
				typ = DDO.PARAM_NULL;
			} else if (value is bool) {
				value = value ? 1 : 0;
				typ = DDO.PARAM_BOOL;
			}
			result.bindValue(x + 1, value, typ);
		}
		Completer c = new Completer();
		result.execute().then((_) {
			c.complete(result);
		});
		return c.future;
	}
}
