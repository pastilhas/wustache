module wustache

fn test_primitives() {
	context := '{ "a": 1337, "b": "hello", "c": 42.01, "d": true }'
	template := '{{a}} {{b}} {{c}} {{d}}'

	res := render(template, context)!
	assert res == '1337 hello 42.01 true'
}

fn test_array() {
	context := '{ "a": [1337, 42, 50] }'
	template := '{{#a}}{{$}} {{/a}}'

	res := render(template, context)!
	assert res == '1337 42 50 '
}

fn test_map() {
	context := '{ "b": { "c": 1337, "d": 53.50 } }'
	template := '{{#b}} {{b.c}} {{b.d}} {{/b}}'

	res := render(template, context)!
	assert res == ' 1337 53.5 '
}

fn test_missing_value() {
	context := '{ "a": 50 }'
	template := '{{game}}'

	render(template, context) or {
		assert err.str() == 'Missing value game'
		return
	}

	assert false
}

fn test_empty_tag() {
	context := '{ "a": 50 }'
	template := '{{}}'

	render_with(template, context, Opts{ allow_empty_tag: false }) or {
		assert err.str().starts_with('Empty tag at')
		return
	}

	assert false
}

fn test_iterator_after_array() {
	context := '{ "a": [1337, 42, 50] }'
	template := '{{#a}}{{$}} {{/a}} {{$}}'

	render(template, context) or {
		assert err.str() == 'Missing value $'
		return
	}

	assert false
}
