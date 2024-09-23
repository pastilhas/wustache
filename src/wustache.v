module wustache

import encoding.html
import x.json2 { Any, raw_decode }

const pos_section = `#`
const neg_section = `^`
const raw_var = `&`
const iter_var = '$'

pub type Value = string | bool | []Value | map[string]Value

pub type Context = map[string]Value

pub struct Opts {
	allow_empty_tag bool = true
	ignore_errors   bool = false
	print_logs      bool = true
}

pub fn from_json(json string) !Context {
	return from_json_with(json, Opts{})!
}

pub fn from_json_with(json string, opts Opts) !Context {
	root := raw_decode(json)!

	if !(opts.ignore_errors || validate(root)) {
		return error('Invalid JSON')
	}

	mut val := decode(root)!

	return if mut val is map[string]Value {
		val
	} else {
		error('Not a map object')
	}
}

fn validate(node Any) bool {
	return match node {
		bool, string {
			true
		}
		[]Any {
			node.all(validate)
		}
		map[string]Any {
			node.values().all(validate)
		}
		else {
			false
		}
	}
}

fn decode(node Any) !Value {
	return match node {
		bool, string {
			Value(node)
		}
		[]Any {
			mut child := []Value{cap: node.len}
			for it in node {
				child << decode(it)!
			}
			child
		}
		map[string]Any {
			mut child := map[string]Value{}
			for key, val in node {
				child[key] = decode(val)!
			}
			child
		}
		else {
			node.str()
		}
	}
}

pub fn render(template string, ctx Context) !string {
	return render_with(template, ctx, Opts{})!
}

pub fn render_with(template string, ctx Context, opts Opts) !string {
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
			return error('Missing end delimiter at ${pointer}')
		}

		if tag.len == 0 {
			// println('Missing tag at ${pointer}')
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
								mut new_ctx := ctx.clone()
								new_ctx[iter_var] = val
								sec := render_section(content, new_ctx, opts)!
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
