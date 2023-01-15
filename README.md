:arrow_upper_left: Table of Contents

# vss

vss is an easy to use static site generator. With `layout/index.html`, Markdown
content, and a little configuration, you can easily build your website!

- **Easy** to use
- Create site content with **Markdown**

<p align="center">
  <img src="./image.gif" alt="vss" width="738">
</p>

![CI](https://github.com/zztkm/vss/workflows/CI/badge.svg)

## Caution

vss is still under development and the API is not stable. Be aware that
disruptive changes may be made!

## Usage

### Setup contents

Currently, be sure to configure the following

```
❯ tree  
.
├── about.md
├── config.toml
├── index.md
├── layouts
│   └── index.html
└── static
    ├── css
    │   └── main.css
    └── js
        └── main.js
```

❯ cat index.md

```markdown
# Open Sea

A static site generator

- [GitHub](https://github.com/zztkm)

[about page](./about.md)
```

❯ cat config.toml

```toml
title = "Open Sea"
description = "Takumi Tsuruta's home page"
base_url = 'https://zztkm.github.io/vss/'
```

❯ cat layouts/index.html

```html
<!DOCTYPE html>

<head>
    <meta charset="utf-8">
    <title>@title</title>
    <base href="@baseUrl">
    <meta name="description" content="@description" />
</head>

<body>
    @contents
</body>
```

Build your site

```
vss build
```

Output

```
❯ tree dist
dist
├── about.html
├── css
│   └── main.css
├── index.html
└── js
    └── main.js
```

❯ cat dist/index.html

```html
<!DOCTYPE html>

<head>
    <meta charset="utf-8">
    <title>Open Sea</title>
    <base href="https://zztkm.github.io/vss/">
    <meta name="description" content="Takumi Tsuruta's home page" />
</head>

<body>
    <h1>Open Sea</h1>
<p>A static site generator</p>
<ul>
<li><a href="https://github.com/zztkm">GitHub</a></li>
</ul>
<p><a href="./about.html">about page</a></p>
</body>
```

## Example

Examples can be found at the
[example](https://github.com/zztkm/vss/tree/main/example) directory.

## Installation

### (Recommended) Install Script

With Shell(For Mac & Linux):

```shell
curl -fsSL https://raw.githubusercontent.com/vssio/vss_install/main/install.sh | sh
```

With PowerShell(for Windows):

```powershell
irm https://raw.githubusercontent.com/vssio/vss_install/main/install.ps1 | iex
```

More information: https://github.com/vssio/vss_install

### Get the binary

Download from [Releases](https://github.com/zztkm/vss/releases)

### Build from source

```
git clone https://github.com/vssio/vss.git
cd vss

v install markdown

v . -o vss
```
