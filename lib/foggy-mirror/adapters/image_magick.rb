# frozen_string_literal: true
require 'shellwords'

module FoggyMirror
  class ImageMagick
    def initialize(path, command: 'convert')
      @path = path
      @command = command
    end

    def dominant_color
      out = `#{@command} #{@path.shellescape} -depth 8 -colors 1 -resize 1x1 txt:-`
      validate_pixel_enumeration!(out)
      out.match(HTML_COLOR_MATCHER)[0]
    end

    def color_samples(res)
      out = `#{@command} #{@path.shellescape} -depth 8 -colors 256 -resize #{res}x#{res}! txt:-`
      validate_pixel_enumeration!(out)
      out.scan(HTML_COLOR_MATCHER)
    end

    private

    def validate_pixel_enumeration!(output)
      raise Error, "convert command didn't return as expected" unless output.start_with?("# ImageMagick pixel")
    end
  end
end
