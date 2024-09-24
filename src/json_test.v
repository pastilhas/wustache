module wustache

fn test_primitives() {
	context := {
		'a': Any(1337)
		'b': 'hello'
		'c': 42.01
		'd': true
	}

	template := '{{a}} {{b}} {{c}} {{d}}'

	res := render(template, context)!
	assert res == '1337 hello 42.01 true'
}

fn test_array() {
	mut context := map[string]Any{}
	context['a'] = [Any(1337), 42, 50]
	context['b'] = [Any('1'), '2', '3']

	template := '{{#a}}{{$}}{{/a}}'

	res := render(template, context)!
	assert res == '13374250'
}

fn test_with_map() {
	mut context := map[string]Any{}
	context['a'] = 'b'
	context['b'] = {
		'c': Any(1337)
	}
	context['c'] = 'c'
	context['d'] = 42.0
	context['e'] = true

	template := '{{#b}} {{b.c}} {{/b}}'

	res := render(template, context)!
	assert res == ' 1337 '
}
