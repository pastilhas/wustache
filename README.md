<div align="center">

[![](https://img.shields.io/badge/Vlang-gray?style=for-the-badge&logo=v)](https://vlang.io/)
[![](https://img.shields.io/badge/WORK%20IN%20PROGRESS-%20rgb(255%2C%20172%2C%2028)%20?style=for-the-badge)](#)
[![](https://img.shields.io/github/forks/Pastilhas/wustache.svg?style=for-the-badge)](#)
[![](https://img.shields.io/github/stars/Pastilhas/wustache.svg?style=for-the-badge)](#)
[![](https://img.shields.io/github/license/Pastilhas/wustache.svg?style=for-the-badge)](#)
  
[![](wustache.png)]()
  
### wustache

</div>

is a lightweight and efficient templating engine written in V. It provides a fast way to render templates with dynamic content. Simple as 1, 2, 3 &mdash; (1) load the `template`, (2) write the `context` as JSON, and (3) execute `render`. It is safe by default, but you can make it less picky.

## Features

- Simple to use API, lightweight and fast;
- Variables &mdash; with HTML escaping by default;
- Conditional sections;
- Nested context and iteration over arrays;
- Error handling.

## Installation

Install the [V language](https://vlang.io/) and run `v install Pastilhas.wustache`

## Usage

```v
template := '{{greet}}, {{name}}. {{#admin}}You are admin.{{/admin}}'
obj := '{ "greet": "Hello", "name": "John", "admin": true }'

res := render(template, obj)!
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

```mustache
{{#never_true}} This will never be seen! {{/never_true}}

{{#is_logged}} Welcome back! {{/is_logged}}

{{#items}}
  {{$.name}}: {{$.price}}
{{/items}}
```

Repeats `content` {0, 1, n} times
- 0, if falsy value &mdash; false, empty string, empty array, empty map;
- 1, if truthy value &mdash; true, non-empty string, non-empty map;
- n, for n-sized array &mdash; each iteration, the value is mapped to `$`

#### Inverted

```mustache
{{^is_logged}}
  {{&login_form}}
{{/is_logged}}
{{#is_logged}}
  Hello, {{user.name}}!
{{/is_logged}}
```

Repeats `content` {0, 1} times &mdash; 0, if truthy, else 1;

## Mustache compatibility

### Planned

- [X] Variables
- [X] Dotted names
- [X] Implicit (with modifications)
- [X] Sections 
- [X] Inverted sections
- [ ] Partials
- [ ] Set delimiter

### Not planned

- [ ] Lambdas
- [ ] Comments
- [ ] Dynamic partials
- [ ] Blocks
- [ ] Parents
- [ ] Dynamic parents

## License

**wustache** is released under the MIT License. See the LICENSE file for details.
