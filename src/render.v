module wustache

import encoding.html

const pos_section = `#`
const neg_section = `^`
const raw_var = `&`
const iter_var = '$'

pub struct Opts {
	allow_empty_tag bool = true
	ignore_errors   bool = false
	print_logs      bool = true
}

struct Template {
mut:
	template string
	context  map[string]Any
	opts     Opts
}

pub fn render(template string, context string) !string {
	m := from_json(context)!
	mut t := Template{template, m, Opts{}}
	return t.render_section()!
}

pub fn render_with(template string, context string, opts Opts) !string {
	m := from_json(context)!
	mut t := Template{template, m, opts}
	return t.render_section()!
}

pub fn render_map(template string, context map[string]Any) !string {
	mut t := Template{template, context, Opts{}}
	return t.render_section()!
}

pub fn render_map_with(template string, context map[string]Any, opts Opts) !string {
	mut t := Template{template, context, opts}
	return t.render_section()!
}

fn (mut t Template) render_section() !string {
	mut result := ''
	mut stag := '{{'
	mut etag := '}}'
	mut pointer := 0
	mut tag := ''

	for {
		if i := t.template.index(stag) {
			result += t.template[..i]
			t.template = t.template[(i + stag.len)..]
			pointer += i + stag.len
		} else {
			result += t.template
			break
		}

		if j := t.template.index(etag) {
			tag = t.template[..j]
			t.template = t.template[(j + etag.len)..]
			pointer += j + stag.len
		} else {
			if !t.opts.ignore_errors {
				return error('Missing end delimiter at ${pointer}')
			}

			continue
		}

		if tag.len == 0 {
			if !t.opts.allow_empty_tag {
				return error('Empty tag at ${pointer}')
			}

			continue
		}

		// TODO: Add comments
		// TODO: Add partials
		// TODO: Add set delimiter
		match tag[0] {
			pos_section {
				section := tag[1..]
				end := '${stag}/${section}${etag}'
				mut content := ''
				if i := t.template.index(end) {
					content = t.template[..i]
					t.template = t.template[(i + end.len)..]
					pointer += i + end.len
				} else {
					if !t.opts.ignore_errors {
						return error('Missing end tag for ${section} at ${pointer}')
					}

					continue
				}

				old_template := t.template.clone()
				t.template = content
				mut val := t.lookup(section)!
				if mut val is []Any {
					// TODO: Optimize re-rendering of static data
					// TODO: Minimize cloning maps
					for it in val {
						old_context := t.context.clone()
						t.context[iter_var] = it
						sec := t.render_section()!
						t.context = old_context.clone()
						t.template = content
						result += sec
					}
				} else {
					if val.bool() {
						sec := t.render_section()!
						result += sec
					}
				}
				t.template = old_template
			}
			neg_section {
				section := tag[1..]
				end := '${stag}/${section}${etag}'
				mut content := ''
				if i := t.template.index(end) {
					content = t.template[..i]
					t.template = t.template[(i + end.len)..]
					pointer += i + end.len
				} else {
					if !t.opts.ignore_errors {
						return error('Missing end tag for ${section} at ${pointer}')
					}

					continue
				}

				old_template := t.template.clone()
				t.template = content
				val := t.lookup(section)!
				if !val.bool() {
					sec := t.render_section()!
					result += sec
				}
				t.template = old_template
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

fn (t Template) lookup(key string) !Any {
	parts := key.split('.')
	mut current := t.context.clone()

	for part in parts {
		if mut val := current[part] {
			if mut val is map[string]Any {
				current = val.clone()
			} else {
				return val
			}
		} else {
			return if t.opts.ignore_errors {
				Any('')
			} else {
				error('Missing value ${key}')
			}
		}
	}

	return Any(current)
}
