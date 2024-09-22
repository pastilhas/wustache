module wustache

import encoding.html
import x.json2

const pos_section = `#`
const neg_section = `^`
const raw_var = `&`
const iter_var = '$'

pub type Value = string | bool | []Value | map[string]Value

pub type Context = map[string]Value

pub struct Opts {
	allow_empty   bool = true
	ignore_errors bool = false
	print_logs    bool = false
}

pub fn Context.from_json(json string) !Context {
	root := json2.raw_decode(json)!
	mut val := decode(root)!

	if mut val is map[string]Value {
		return val
	} else {
		return error('json is not map of values')
	}
}

fn decode(node json2.Any) !Value {
	return match node {
		bool, string {
			Value(node)
		}
		[]json2.Any {
			mut child := []Value{cap: node.len}
			for it in node {
				child << decode(it)!
			}
			child
		}
		map[string]json2.Any {
			mut child := map[string]Value{}
			for key, val in node {
				child[key] = decode(val)!
			}
			child
		}
		else {
			return error('Unsupported type: ${typeof(node).name}')
		}
	}
}

pub fn render(template string, ctx Context) !string {
	return render_section(template, ctx)!
}

fn render_section(template string, ctx Context) !string {
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
			return error('Missing end delimiter at ${pointer}')
		}

		if tag.len == 0 {
			println('Missing tag at ${pointer}')
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
					return error('Missing end tag for ${section} at ${pointer}')
				}

				if val := lookup(section, ctx) {
					match val {
						string {
							if val.len > 0 {
								sec := render_section(content, ctx)!
								result += sec
							}
						}
						bool {
							if val {
								sec := render_section(content, ctx)!
								result += sec
							}
						}
						[]Value {
							for it in val {
								mut new_ctx := ctx.clone()
								new_ctx[iter_var] = it
								sec := render_section(content, new_ctx)!
								result += sec
							}
						}
						map[string]Value {
							if val.keys().len > 0 {
								mut new_ctx := ctx.clone()
								new_ctx[iter_var] = val
								sec := render_section(content, new_ctx)!
								result += sec
							}
						}
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
					return error('Missing end tag for ${section} at ${pointer}')
				}

				if val := lookup(section, ctx) {
					match val {
						string {
							if val.len == 0 {
								sec := render_section(content, ctx)!
								result += sec
							}
						}
						bool {
							if !val {
								sec := render_section(content, ctx)!
								result += sec
							}
						}
						[]Value {
							if val.len == 0 {
								sec := render_section(content, ctx)!
								result += sec
							}
						}
						map[string]Value {
							if val.keys().len == 0 {
								sec := render_section(content, ctx)!
								result += sec
							}
						}
					}
				}
			}
			raw_var {
				if val := lookup(tag[1..], ctx) {
					result += val2str(val)
				}
			}
			else {
				if val := lookup(tag, ctx) {
					result += html.escape(val2str(val))
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
