module main

fn main() {
	template := 'Hello {{name}}. {{#admin}}You are admin{{/admin}}'

	mut ctx := map[string]ContextValue{}
	ctx['name'] = 'joao'
	ctx['admin'] = false

	res := render(template, ctx)!

	println(res)
}
