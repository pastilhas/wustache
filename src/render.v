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

pub fn render(template string, context map[string]Any) !string {
	return render_with(template, context, Opts{})!
}

pub fn render_with(template string, context map[string]Any, opts Opts) !string {
	return render_section(template, context, opts)!
}

fn render_section(template string, context map[string]Any, opts Opts) !string {
	mut temp := template
	mut result := ''
	mut stag := '{{'
	mut etag := '}}'
	mut pointer := 0
	mut tag := ''

	for {
		if i := temp.index(stag) {
			result += temp[..i]
			temp = temp[(i + stag.len)..]
			pointer += i + stag.len
		} else {
			result += temp
			break
		}

		if j := temp.index(etag) {
			tag = temp[..j]
			temp = temp[(j + etag.len)..]
			pointer += j + stag.len
		} else {
			if !opts.ignore_errors {
				return error('Missing end delimiter at ${pointer}')
			}

			continue
		}

		if tag.len == 0 {
			if !opts.allow_empty_tag {
				return error('Empty tag at ${pointer}')
			}

			continue
		}

		match tag[0] {
			pos_section {
				section := tag[1..]
				end := '${stag}/${section}${etag}'
				mut content := ''
				if i := temp.index(end) {
					content = temp[..i]
					temp = temp[(i + end.len)..]
					pointer += i + end.len
				} else {
					if !opts.ignore_errors {
						return error('Missing end tag for ${section} at ${pointer}')
					}

					continue
				}

				mut val := lookup(section, context)!
				if mut val is []Any {
					for it in val {
						mut new_context := context.clone()
						new_context[iter_var] = it
						sec := render_section(content, new_context, opts)!
						result += sec
					}
				} else {
					if val.bool() {
						sec := render_section(content, context, opts)!
						result += sec
					}
				}
			}
			neg_section {
				section := tag[1..]
				end := '${stag}/${section}${etag}'
				mut content := ''
				if i := temp.index(end) {
					content = temp[..i]
					temp = temp[(i + end.len)..]
					pointer += i + end.len
				} else {
					if !opts.ignore_errors {
						return error('Missing end tag for ${section} at ${pointer}')
					}

					continue
				}

				val := lookup(section, context)!
				if !val.bool() {
					sec := render_section(content, context, opts)!
					result += sec
				}
			}
			raw_var {
				val := lookup(tag[1..], context)!
				result += val.str()
			}
			else {
				val := lookup(tag, context)!
				result += html.escape(val.str())
			}
		}
	}

	return result
}

fn lookup(key string, context map[string]Any) !Any {
	parts := key.split('.')
	mut current := context.clone()

	for part in parts {
		if mut val := current[part] {
			if mut val is map[string]Any {
				current = val.clone()
			} else {
				return val
			}
		} else {
			return error('Missing value ${key}')
		}
	}

	return Any(current)
}
