module main

fn main() {
	template := 'Hello {{name}}. {{#admin}}You are admin{{/admin}}'

	mut ctx := map[string]WValue{}
	ctx['name'] = 'joao'
	ctx['admin'] = true

	res := render(template, ctx)!
	println(res)
}
