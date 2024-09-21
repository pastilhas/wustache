module main

import regex

pub type WValue = string | int | f32 | f64 | bool | []WValue | map[string]WValue

pub struct Template {
mut:
	template string
}

pub fn new_template(template string) Template {
	return Template{
		template: template
	}
}

pub fn (t Template) render(ctx map[string]WValue) !string {
	mut result := t.template
	result = t.render_single(result, ctx)!
	result = t.render_conditional(result, ctx)!
	return result
}

fn (t Template) render_single(result string, ctx map[string]WValue) !string {
	mut res := result

	pattern := r'\{\{\w+\}\}'
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

fn (t Template) render_conditional(result string, ctx map[string]WValue) !string {
	mut res := result

	pattern := r'\{\{#(\w+)\}\}(.*)\{\{/(\w+)\}\}'
	mut re := regex.regex_opt(pattern)!
	matches := re.find_all_str(result)

	for m in matches {
		k1 := re.get_group_by_id(m, 0)
		k2 := re.get_group_by_id(m, 2)
		content := re.get_group_by_id(m, 1)

		if k1 != k2 {
			continue
		}

		if val := ctx[k1] {
			iter := n_iter(val)
			arr := []string{len: iter, init: content}
			res = res.replace(m, arr.join(''))
		}
	}

	return res
}

fn val2str(value WValue) string {
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
		[]WValue {
			value.map(val2str).join(', ')
		}
		map[string]WValue {
			'{${value.keys().join(', ')}}'
		}
	}
}

fn n_iter(value WValue) int {
	return match value {
		string {
			if value.len > 0 {
				1
			} else {
				0
			}
		}
		int {
			if value != 0 {
				1
			} else {
				0
			}
		}
		f32 {
			if value != 0 {
				1
			} else {
				0
			}
		}
		f64 {
			if value != 0 {
				1
			} else {
				0
			}
		}
		bool {
			if value {
				1
			} else {
				0
			}
		}
		[]WValue {
			value.len
		}
		map[string]WValue {
			value.keys().len
		}
	}
}

pub fn render(template string, ctx map[string]WValue) !string {
	t := new_template(template)
	return t.render(ctx)!
}
