<div align="center">
<img src="wustache.png" alt="drawing" width="100"/>

<h1>WUSTACHE</h1>

[![Built][BuiltBadge]][BuiltUrl]
![WIP][WIPBadge]
</div>

Wustache is a lightweight and efficient Mustache-like templating engine
implemented in V. It provides a simple way to render templates with dynamic
content using a context map.

## Features

- Simple to use, lightweight and fast;
- Variable interpolation &mdash; with HTML escaping by default;
- Conditional sections &mdash; normal and inverted;
- Nested context with dot notation;
- Iteration over arrays;
- Context from JSON string;
- Options to control error handling.

## Installation

Install the [V programming language](https://vlang.io/). Then, run:
```v install Pastilhas.wustache``` 

## Usage

```v
template := '{{greet}}, {{name}}. {{#admin}}You are admin.{{/admin}}'
obj := '{ "greet": "Hello", "name": "John", "admin": true }'

ctx := from_json(code)!
res := render(template, ctx)!
println(res) // 'Hello, John. You are admin.'
```

### Interpolation

`{{variable}}`

Returns the string value of `variable`, espacing HTML

`{{&raw_variable}}`

Returns the string value of `raw_variable`, without escaping

### Section

`{{#variable}} <content> {{/variable}}`

Repeats the content 0, 1, or n times. 
- 0 if falsy value &mdash; false, empty string, empty array, empty map;
- 1 if truthy value &mdash; true, non-empty string, non-empty map;
- n for n-sized array

### Inverted section

`{{^variable}} <content> {{/variable}}`

Repeats the content 0 or 1 times. 
- 0 if truthy value;
- 1 if falsy value;

### Nested context

`{{person.age}}`

Map fields can be used with dot notation.

`{{#persons}} {{$.age}} {{/persons}}`

Inside sections, the current item is stored in context as `$`

## License

Wustache is released under the MIT License. See the LICENSE file for details.

[BuiltUrl]: https://vlang.io/
[BuiltBadge]: https://img.shields.io/badge/Vlang-gray?style=for-the-badge&logo=v
[WIPBadge]: https://img.shields.io/badge/WORK%20IN%20PROGRESS-%20rgb(255%2C%20172%2C%2028)%20?style=for-the-badge
