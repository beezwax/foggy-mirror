# frozen_string_literal: true

module FoggyMirror
  class Error < StandardError; end

  HTML_COLOR_MATCHER = /#[A-F0-9]{6}/.freeze

  DEFAULT_RESOLUTION = 5

  ADAPTERS = {
    vips:   -> { FoggyMirror::Vips },
    magick: -> { FoggyMirror::ImageMagick }
  }.freeze

  autoload :Processor,   'foggy-mirror/processor'
  autoload :Color,       'foggy-mirror/color'
  autoload :Blob,        'foggy-mirror/blob'
  autoload :CLI,         'foggy-mirror/cli'
  autoload :Utils,       'foggy-mirror/utils'
  autoload :ImageMagick, 'foggy-mirror/adapters/image_magick'
  autoload :Vips,        'foggy-mirror/adapters/vips'
  autoload :Exporter,    'foggy-mirror/exporter'
  autoload :CSS,         'foggy-mirror/exporters/css'
  autoload :SVG,         'foggy-mirror/exporters/svg'
end
