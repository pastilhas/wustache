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
	stag     string = '{{'
	etag     string = '}}'
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
	mut t := new_template(template, m, opts)
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
	mut tag := ''

	for {
		i := t.template.index(t.stag) or {
			result += t.template
			break
		}

		result += t.template[..i]
		t.template = t.template[(i + t.stag.len)..]
		t.pointer += i + t.stag.len

		j := t.template.index(t.etag) or {
			if t.opts.ignore_errors {
				continue
			}
			return error('Missing end delimiter at ${t.pointer}')
		}

		tag = t.template[..j]
		t.template = t.template[(j + t.etag.len)..]
		t.pointer += j + t.stag.len

		if tag.len == 0 {
			if t.opts.allow_empty_tag {
				continue
			}
			return error('Empty tag at ${t.pointer}')
		}

		// TODO: Add partials
		// TODO: Add set delimiter
		result += match tag[0] {
			pos_section {
				t.render_sub_section(tag, true) or {
					if t.opts.ignore_errors {
						continue
					}
					return err
				}
			}
			neg_section {
				t.render_sub_section(tag, false) or {
					if t.opts.ignore_errors {
						continue
					}
					return err
				}
			}
			raw_var {
				val := t.lookup(tag[1..])!
				val.str()
			}
			else {
				val := t.lookup(tag)!
				html.escape(val.str())
			}
		}
	}

	return result
}

fn (mut t Template) render_sub_section(tag string, positive bool) !string {
	key := tag[1..]
	end := '${t.stag}/${key}${t.etag}'
	mut content := ''
	mut result := ''

	i := t.template.index(end) or { return error('Missing end tag for ${key} at ${t.pointer}') }

	content = t.template[..i]
	t.template = t.template[(i + end.len)..]
	t.pointer += i + end.len

	mut it_t := new_template(content, t.context.clone(), t.opts)
	mut val := it_t.lookup(key)!

	if positive {
		if mut val is []Any {
			// TODO: Optimize re-rendering of static data
			for it in val {
				it_t.context[iter_var] = it

				result += it_t.render_section()!

				it_t.template = content
			}
		} else if val.bool() {
			result = it_t.render_section()!
		}
	} else if !val.bool() {
		result = it_t.render_section()!
	}

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
