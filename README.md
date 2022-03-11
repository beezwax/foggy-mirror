# foggy-mirror

[![Gem Version](https://badge.fury.io/rb/foggy-mirror.svg?style=flat)](https://rubygems.org/gems/foggy-mirror)
![CI](https://github.com/beezwax/foggy-mirror/workflows/CI/badge.svg)
[![Powered by Beezwax](https://img.shields.io/badge/Powered%20By-Beezwax-gold?logo=data:image/svg+xml;charset=utf-8;base64,PHN2ZyB3aWR0aD0iMTA5IiBoZWlnaHQ9IjEwOSIgdmlld0JveD0iMCAwIDEwOSAxMDkiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+DQogICA8Zz4NCiAgICAgIDxwYXRoIGQ9Ik01MC44IDEwNi42MjVDNTkuMSA5OS4zMjUgNjEuOSA5MS42MjUgNjEuOSA5MS42MjVDNjMuMiA4Ny43MjUgNjQuNyA4NC41MjUgNjQuNyA2OS4zMjVDNjQuNyA0Ni40MjUgNTYuMiAzOC45MjUgNDcgMzIuMDI1QzQwLjggMjcuMzI1IDI0LjkgMjEuMTI1IDE1LjUgMTcuNjI1TDIuMjk5OTggMjUuMTI1QzEuNDk5OTggMjUuNzI1IDAuOTk5OTc2IDI2LjIyNSAwLjU5OTk3NiAyNi44MjVDMjQuNCAzMi4xMjUgNDEuNSA0OC4wMjUgNDEuNSA2Ni44MjVDNDEuNSA3OC4yMjUgMzUuMSA4OC42MjUgMjQuOSA5Ni4xMjVMNDQuNyAxMDcuNTI1QzQ1LjEgMTA3LjcyNSA0NiAxMDguMTI1IDQ3LjMgMTA4LjEyNUM0Ny45IDEwOC4xMjUgNDkgMTA3LjkyNSA1MC4zIDEwNi44MjVMNTAuOCAxMDYuNjI1WiIgZmlsbD0iI0ZGRDkzOSI+PC9wYXRoPg0KICAgICAgPHBhdGggZD0iTTIyLjkgMTMuMzI0OEw0NCAyMC40MjQ4QzY0LjYgMjcuNzI0OCA3My4yIDM3LjgyNDggNzMuMiAzNy44MjQ4Qzg0LjUgNDkuMTI0OCA4My4yIDYxLjYyNDggODMuMiA3Ni44MjQ4QzgzLjIgODAuNjI0OCA4Mi42IDg0LjkyNDggODEuNyA4OS4wMjQ4TDkzIDgyLjYyNDhDOTUuNiA4MS4xMjQ4IDk1LjYgNzcuOTI0OCA5NS42IDc3LjkyNDhWMjkuMzI0OEM5NS42IDI2LjEyNDggOTMgMjQuNjI0OCA5MyAyNC42MjQ4TDcyLjUgMTMuMjI0OEw1MC42IDAuNjI0ODQ1QzQ4LjEgLTAuNjc1MTU1IDQ1LjUgMC40MjQ4NDUgNDUuMyAwLjYyNDg0NUwyMy4xIDEzLjMyNDhIMjIuOVoiIGZpbGw9IiNGRkQ5MzkiPjwvcGF0aD4NCiAgICAgIDxwYXRoIGQ9Ik0wLjEgMzEuNTI0NFY3OC4yMjQ0QzAuMSA4MC44MjQ0IDIuMiA4Mi4zMjQ0IDIuNyA4Mi43MjQ0TDE0LjggODkuNjI0NEwxNy44IDkxLjMyNDRDMjQuNCA4NC43MjQ0IDI4LjQgNzYuMzI0NCAyOC41IDY3LjEyNDRDMjguNSA1MS41MjQ0IDE2LjggMzguMDI0NCAwIDMxLjUyNDRIMC4xWiIgZmlsbD0iI0ZGRDkzOSI+PC9wYXRoPg0KICAgPC9nPg0KPC9zdmc+)](https://beezwax.net/)

foggy-mirror is a small Ruby tool that creates faux blurry versions of raster
images using radial gradients, exported as either SVG or CSS (using
`background-image`).

This is useful as a poor man's replacement for CSS's `backdrop-filter: blur()`,
as that CSS feature isn't fully supported by browsers, and sometimes you want
an element with a "frosted glass" effect on top of a crispy background.

Using gradients we can achieve very smooth and infinitely scalable graphics at
very low file size (e.g. the example SVG below is only 814 bytes after gzip).
If you need a less blurry version of the original picture, then a regular blur
effect saved to JPEG/WebP may be a better value proposition.

Need Ruby/Rails consulting? Contact us at [Beezwax.net](https://beezwax.net/)

## Example

Original raster image:

![Photo by Marek Piwnicki (@marekpiwnicki) / Unsplash](/img/unsplash-sq.webp)

SVG:

<img src="/img/unsplash.svg" alt="foggy-mirror SVG" width="500" height="500" />

## Installation

In your Gemfile:

```ruby
gem 'foggy-mirror'
```

## Usage

Within Ruby:

```ruby
require 'foggy-mirror'

# All keyword arguments are optional, only the filename is required
p = FoggyMirror::Processor.new("/path/to/image.jpg",
  resolution:      5,
  overlap:         0.5,
  distribution:    :shuffle,
  random_offset:   0.5,
  random:          Random.new,
  adapter:         FoggyMirror::ImageMagick,
  adapter_options: {}
)

p.to_svg # Outputs SVG

p.to_css # Outputs CSS properties
```

Options are:

* `resolution` (Integer): How many radial gradients to use per dimension (X/Y).
  Defaults to 5.
* `overlap` (Float): How much radial gradients overlap each other (0 means no
  overlap). Defaults to 0.5.
* `distribution` (Symbol/String): How to distribute the radial gradients. Since
  they can overlap each other, their position on the Z-axis affects the final
  result. Accepted values are `:scan` (default), `:scan_reverse`, `:suffle`,
  `:spiral_in` and `:spiral_out`.
* `random_offset` (Float): How much to randomly offset the center of each
  radial gradient, which can create a more natural looking result (0 means no
  offset). Defaults to 0.5.
* `random` (Random instance): The Random instance to use for generating random
  values, in case you need it to be deterministic.
* `adapter` (Class): the adapter to use for reading and processing image files.
  Supported adapters are `FoggyMirror::ImageMagick` (uses CLI commands) and
  `FoggyMirror::Vips` (fastest, but requires installing `ruby-vips` gem).
* `adapter_options` (Hash): options to pass to the adapter on initialization.
