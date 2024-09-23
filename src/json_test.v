module main

import wustache { Opts, from_json }

fn test_decode_non_map() {
	code := '"This is not a map"'
	from_json(code, Opts{}) or {
		assert err.str() == 'Not a map object'
		return
	}

	assert false
}

fn test_decode_non_map2() {
	code := '["A", "B", "C"]'
	from_json(code, Opts{}) or {
		assert err.str() == 'Not a map object'
		return
	}

	assert false
}

fn test_decode_map() {
	code := '{
		"a": "b",
		"b": "1337",
		"c": "d",
		"d": "42",
		"e": true
	}'
	if res := from_json(code, Opts{}) {
		assert res['a'] is string && res['a'] == 'b'
		assert res['b'] is string && res['b'] == '1337'
		assert res['c'] is string && res['c'] == 'd'
		assert res['d'] is string && res['d'] == '42'
		assert res['e'] is bool && res['e'] == true

		return
	}

	assert false
}
