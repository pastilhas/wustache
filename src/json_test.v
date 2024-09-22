module main

import wustache { from_json }

fn test_decode_non_map() {
	code := '"This is not a map"'
	from_json(code) or {
		assert err.str() == 'Not a map object'
		return
	}

	assert false
}

fn test_decode_non_map2() {
	code := '["A", "B", "C"]'
	from_json(code) or {
		assert err.str() == 'Not a map object'
		return
	}

	assert false
}

fn test_decode_map() {
	code := '{"a": "b", "c": "d", "b": 1337, "d": 42, "e": true}'
	if res := from_json(code) {
		assert res['a'] is string
		assert res['b'] is string
		assert res['c'] is string
		assert res['d'] is string
		assert res['e'] is bool
		return
	}

	assert false
}
