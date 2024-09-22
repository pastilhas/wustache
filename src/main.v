module main

fn main() {
	template := 'Hello {{name}}. {{#admin}}You are admin{{/admin}}'

	mut ctx := map[string]Value{}
	ctx['name'] = 'joao'
	ctx['admin'] = [Value(1), 2, 3, 4]

	res := render(template, ctx)!
	println(res)
}
