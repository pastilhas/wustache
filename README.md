<div align="center">
<a href="#"><img src="wustache.png" alt="drawing" width="100"/></a>

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

```mustache
Hello, {{name}}.

Welcome, {{user.name}}. You have {{user.unread}} messages.

<div class="user-card">
  {{&raw_variable}}
</div>
```

### Sections

#### Normal
```mustache
{{#never_true}} This will never be seen! {{/never_true}}

{{#is_logged}} Welcome back! {{/is_logged}}

{{#items}}
  {{$.name}}: {{$.price}}
{{/items}}
```

Repeats `content` {0, 1, n} times
- 0 if falsy value &mdash; false, empty string, empty array, empty map;
- 1 if truthy value &mdash; true, non-empty string, non-empty map;
- n for n-sized array &mdash; each iteration, the value is mapped to `$`

#### Inverted

```mustache
{{^is_logged}}
  {{&login_form}}
{{/is_logged}}
{{#is_logged}}
  Hello, {{user.name}}!
{{/is_logged}}
```

Repeats `content` {0, 1} times
- 0 if truthy value;
- 1 if falsy value;

## License

Wustache is released under the MIT License. See the LICENSE file for details.

[BuiltUrl]: https://vlang.io/
[BuiltBadge]: https://img.shields.io/badge/Vlang-gray?style=for-the-badge&logo=v
[WIPBadge]: https://img.shields.io/badge/WORK%20IN%20PROGRESS-%20rgb(255%2C%20172%2C%2028)%20?style=for-the-badge
