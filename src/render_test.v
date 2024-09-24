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
