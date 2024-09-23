module wustache

import encoding.html

const pos_section = `#`
const neg_section = `^`
const raw_var = `&`
const iter_var = '$'

type Value = string | bool | []Value | map[string]Value

type Context = map[string]Value

pub struct Opts {
	allow_empty_tag bool = true
	ignore_errors   bool = false
	print_logs      bool = true
}

pub fn render(template string, context string) !string {
	return render_with(template, context, Opts{})!
}

pub fn render_with(template string, context string, opts Opts) !string {
	ctx := from_json_with(context, opts)!
	return render_section(template, ctx, opts)!
}

fn render_section(template string, ctx Context, opts Opts) !string {
	mut temp := template
	mut result := ''
	mut stag := '{{'
	mut etag := '}}'
	mut pointer := 0

	for {
		if i := temp.index(stag) {
			result += temp[..i]
			temp = temp[(i + stag.len)..]
			pointer += i + stag.len
		} else {
			result += temp
			break
		}

		mut tag := ''

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

				if val := lookup(section, ctx) {
					match val {
						string {
							if val.len > 0 && val != '0' && val != '0.0' {
								sec := render_section(content, ctx, opts)!
								result += sec
							}
						}
						bool {
							if val {
								sec := render_section(content, ctx, opts)!
								result += sec
							}
						}
						[]Value {
							for it in val {
								mut new_ctx := ctx.clone()
								new_ctx[iter_var] = it
								sec := render_section(content, new_ctx, opts)!
								result += sec
							}
						}
						map[string]Value {
							if val.keys().len > 0 {
								sec := render_section(content, ctx, opts)!
								result += sec
							}
						}
					}
				} else {
					if !opts.ignore_errors {
						return error('Missing value ${tag[1..]}')
					}

					continue
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

				if val := lookup(section, ctx) {
					match val {
						string {
							if val.len == 0 {
								sec := render_section(content, ctx, opts)!
								result += sec
							}
						}
						bool {
							if !val {
								sec := render_section(content, ctx, opts)!
								result += sec
							}
						}
						[]Value {
							if val.len == 0 {
								sec := render_section(content, ctx, opts)!
								result += sec
							}
						}
						map[string]Value {
							if val.keys().len == 0 {
								sec := render_section(content, ctx, opts)!
								result += sec
							}
						}
					}
				}
			}
			raw_var {
				if val := lookup(tag[1..], ctx) {
					result += val2str(val)
				} else {
					if !opts.ignore_errors {
						return error('Missing value ${tag[1..]}')
					}

					continue
				}
			}
			else {
				if val := lookup(tag, ctx) {
					result += html.escape(val2str(val))
				} else {
					if !opts.ignore_errors {
						return error('Missing value ${tag[1..]}')
					}

					continue
				}
			}
		}
	}

	return result
}

fn lookup(key string, ctx Context) ?Value {
	parts := key.split('.')
	mut current := ctx

	for part in parts {
		if mut val := current[part] {
			if mut val is map[string]Value {
				current = val
			} else {
				return val
			}
		} else {
			return none
		}
	}

	return current
}

fn val2str(value Value) string {
	return match value {
		string {
			value
		}
		bool {
			value.str()
		}
		[]Value {
			value.map(val2str).join(', ')
		}
		map[string]Value {
			'{${value.keys().join(', ')}}'
		}
	}
}
