module wustache

import x.json2 { Any, raw_decode }

fn from_json(json string) !Context {
	return from_json_with(json, Opts{})!
}

fn from_json_with(json string, opts Opts) !Context {
	root := raw_decode(json)!

	if !(opts.ignore_errors || validate(root)) {
		return error('Invalid JSON')
	}

	mut val := decode(root)

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

fn decode(node Any) Value {
	return match node {
		bool, string {
			Value(node)
		}
		[]Any {
			mut child := []Value{cap: node.len}
			for it in node {
				child << decode(it)
			}
			child
		}
		map[string]Any {
			mut child := map[string]Value{}
			for key, val in node {
				child[key] = decode(val)
			}
			child
		}
		else {
			node.str()
		}
	}
}
