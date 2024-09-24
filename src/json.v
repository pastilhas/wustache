module wustache

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

pub fn (f Any) bool() bool {
	return match f {
		bool {
			f
		}
		string {
			f == 'true' || (f != 'false' && f != '0' && f != '0.0' && f.len > 0)
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

pub fn (f Any) str() string {
	return match f {
		string {
			f
		}
		bool {
			if f {
				'true'
			} else {
				'false'
			}
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
	}
}
