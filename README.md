# foggy-mirror

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
