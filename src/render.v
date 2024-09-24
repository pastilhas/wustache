module wustache

import encoding.html

const pos_section = `#`
const neg_section = `^`
const raw_var = `&`
const iter_var = '$'

pub struct Opts {
	allow_empty_tag bool = true
	ignore_errors   bool
	print_logs      bool = true
}

struct Template {
mut:
	template string
	context  map[string]Any
	opts     Opts
	pointer  int
}

fn new_template(t string, c map[string]Any, o Opts) Template {
	return Template{
		template: t
		context:  c
		opts:     o
		pointer:  0
	}
}

pub fn render(template string, context string) !string {
	m := from_json(context)!
	mut t := new_template(template, m, Opts{})
	return t.render_section()!
}

pub fn render_with(template string, context string, opts Opts) !string {
	m := from_json(context)!
	mut t := new_template(template, m, Opts{})
	return t.render_section()!
}

pub fn render_map(template string, context map[string]Any) !string {
	mut t := new_template(template, context, Opts{})
	return t.render_section()!
}

pub fn render_map_with(template string, context map[string]Any, opts Opts) !string {
	mut t := new_template(template, context, opts)
	return t.render_section()!
}

fn (mut t Template) render_section() !string {
	mut result := ''
	mut stag := '{{'
	mut etag := '}}'
	mut tag := ''

	for {
		i := t.template.index(stag) or {
			result += t.template
			break
		}

		result += t.template[..i]
		t.template = t.template[(i + stag.len)..]
		t.pointer += i + stag.len

		j := t.template.index(etag) or {
			if t.opts.ignore_errors {
				continue
			}
			return error('Missing end delimiter at ${t.pointer}')
		}

		tag = t.template[..j]
		t.template = t.template[(j + etag.len)..]
		t.pointer += j + stag.len

		if tag.len == 0 {
			if t.opts.allow_empty_tag {
				continue
			}
			return error('Empty tag at ${t.pointer}')
		}

		// TODO: Add comments
		// TODO: Add partials
		// TODO: Add set delimiter
		match tag[0] {
			pos_section {
				key := tag[1..]
				end := '${stag}/${key}${etag}'
				result += t.render_sub_section(key, end, true) or {
					if t.opts.ignore_errors {
						continue
					}
					return err
				}
			}
			neg_section {
				key := tag[1..]
				end := '${stag}/${key}${etag}'
				result += t.render_sub_section(key, end, false) or {
					if t.opts.ignore_errors {
						continue
					}
					return err
				}
			}
			raw_var {
				val := t.lookup(tag[1..])!
				result += val.str()
			}
			else {
				val := t.lookup(tag)!
				result += html.escape(val.str())
			}
		}
	}

	return result
}

fn (mut t Template) render_sub_section(key string, end string, positive bool) !string {
	mut content := ''
	mut result := ''

	i := t.template.index(end) or { return error('Missing end tag for ${key} at ${t.pointer}') }

	content = t.template[..i]
	t.template = t.template[(i + end.len)..]
	t.pointer += i + end.len

	old_template := t.template.clone()
	t.template = content

	mut val := t.lookup(key)!

	if positive {
		if mut val is []Any {
			// TODO: Optimize re-rendering of static data
			// TODO: Minimize cloning maps
			for it in val {
				old_context := t.context.clone()
				t.context[iter_var] = it

				result += t.render_section()!

				t.context = old_context.clone()
				t.template = content
			}
		} else {
			if val.bool() {
				result = t.render_section()!
			}
		}
	} else {
		if !val.bool() {
			result = t.render_section()!
		}
	}

	t.template = old_template
	return result
}

fn (t Template) lookup(key string) !Any {
	parts := key.split('.')
	mut current := unsafe { &t.context }

	for i, part in parts {
		mut val := unsafe {
			current[part] or { break }
		}

		if i == parts.len - 1 {
			return val
		}

		if mut val is map[string]Any {
			current = &val
			continue
		}

		break
	}

	return if t.opts.ignore_errors {
		Any('')
	} else {
		error('Missing value ${key}')
	}
}
