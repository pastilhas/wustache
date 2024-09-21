module main

import regex

pub type ContextValue = string
	| int
	| f32
	| f64
	| bool
	| []ContextValue
	| map[string]ContextValue

pub struct Template {
mut:
	template string
}

pub fn new_template(template string) Template {
	return Template{
		template: template
	}
}

pub fn (t Template) render(ctx map[string]ContextValue) !string {
	mut result := t.template
	result = t.render_single(result, ctx)!
	return result
}

fn (t Template) render_single(result string, ctx map[string]ContextValue) !string {
	mut res := result

	pattern := r'\{\{[0-9a-zA-Z_]+\}\}'
	mut re := regex.regex_opt(pattern)!

	matches := re.find_all_str(result)
	for m in matches {
		k := m[2..(m.len - 2)]

		if val := ctx[k] {
			res = res.replace(m, val2str(val))
		}
	}

	return res
}

fn val2str(value ContextValue) string {
	return match value {
		string {
			value
		}
		int {
			value.str()
		}
		f32 {
			value.str()
		}
		f64 {
			value.str()
		}
		bool {
			value.str()
		}
		[]ContextValue {
			value.map(val2str).join(', ')
		}
		map[string]ContextValue {
			'{${value.keys().join(', ')}}'
		}
	}
}

pub fn render(template string, ctx map[string]ContextValue) !string {
	t := new_template(template)
	return t.render(ctx)!
}
