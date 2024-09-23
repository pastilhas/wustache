# Wustache

Wustache is a lightweight and efficient Mustache-like templating engine
implemented in V. It provides a simple way to render templates with dynamic
content using a context map.

## Features

- Variable interpolation with HTML escaping
- Sections and inverted sections support
- Raw variable output (unescaped)
- Nested context lookup with dot notation
- Iteration over arrays and maps
- Lightweight and fast

## Installation

Install the [V programming language](https://vlang.io/). Then, run:
```v install Pastilhas.wustache``` 

## Usage

```v
template := '{{greet}}, {{name}}. {{#admin}}You are admin.{{/admin}}'
obj := '{ "greet": "Hello", "name": "John", "admin": true }'

ctx := from_json(code)!
res := render(template, ctx)!
println(res)
```

## License

Wustache is released under the MIT License. See the LICENSE file for details.