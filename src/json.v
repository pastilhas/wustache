module wustache

import x.json2 { raw_decode }

pub type Any = string
	| map[string]Any
	| []Any
	| bool
	| f64
	| f32
	| i64
	| int
	| i16
	| i8
	| u64
	| u32
	| u16
	| u8

pub fn from_json(str string) !map[string]Any {
	obj := raw_decode(str)!
	mut res := convert(obj)!

	return if mut res is map[string]Any {
		res
	} else {
		error('Not a map')
	}
}

fn convert(obj json2.Any) !Any {
	return match obj {
		bool, string, i8, i16, int, i64, u8, u16, u32, u64, f32, f64 {
			Any(obj)
		}
		[]json2.Any {
			mut a := []Any{cap: obj.len}
			for it in obj {
				a << convert(it)!
			}
			a
		}
		map[string]json2.Any {
			mut m := map[string]Any{}
			for k, v in obj {
				m[k] = convert(v)!
			}
			m
		}
		else {
			error('Invalid type')
		}
	}
}

fn (f Any) bool() bool {
	return match f {
		bool {
			f
		}
		string {
			f == 'true' || (f != 'false' && f != '0' && f != '0.0' && f != '')
		}
		i8, i16, int, i64 {
			i64(f) != 0
		}
		u8, u16, u32, u64 {
			u64(f) != 0
		}
		f32, f64 {
			f64(f) != 0.0
		}
		[]Any {
			f.len > 0
		}
		map[string]Any {
			f.keys().len > 0
		}
	}
}

fn (f Any) str() string {
	return match f {
		string {
			f
		}
		[]Any {
			'${f.map(|it| it.str()).join(', ')}'
		}
		map[string]Any {
			'${f.keys().map(|it| it.str()).join(', ')}'
		}
		i8, i16, int, i64 {
			i64(f).str()
		}
		u8, u16, u32, u64 {
			u64(f).str()
		}
		f32, f64 {
			f64(f).str()
		}
		bool {
			f.str()
		}
	}
}
