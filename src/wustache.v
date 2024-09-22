module main

pub type Value = string | int | f32 | f64 | bool | []Value | map[string]Value

pub type Context = map[string]Value

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
			return error('Missing end tag at ${pointer}')
		}

		if tag.len == 0 {
			println('Missing tag at ${pointer}')
			continue
		}

		match tag[0] {
			`#` {
				println('Not implemented')
			}
			`^` {
				println('Not implemented')
			}
			`&` {
				println('Not implemented')
			}
			`{` {
				println('Not implemented')
			}
			else {
				println('Not implemented')
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
