# frozen_string_literal: true
begin
  require 'vips'
rescue LoadError
  raise LoadError, "Couldn't load 'vips' library, do you have ruby-vips in your Gemfile?"
end

module FoggyMirror
  class Vips
    include Utils

    def initialize(path)
      @path = path
    end

    def dominant_color
      html_color *color_avg(load_image(DEFAULT_RESOLUTION))
    end

    def color_samples(res)
      square_image(res).to_a.flatten(1).map { |rgb| html_color *rgb }
    end

    private

    def square_image(res)
      # We load the image as a thumbnail, shrinking it to double the resolution
      # requested, making use of libvips' shrink-on-load optimization, which
      # should be way faster than loading the entire image and shrinking.
      #
      # This optimization assumes the original image isn't more than twice as
      # wide as it is high, or vice-versa.
      im = load_image(res * 2)

      # Make the image square
      if im.width > im.height
        im = im.reduceh(im.width.to_f / im.height)
      elsif im.height > im.width
        im = im.reducev(im.height.to_f / im.width)
      end

      im.resize(res.to_f / im.width)
    end

    def load_image(res)
      ::Vips::Image.thumbnail(@path, res)
    end

    def color_avg(image)
      image.stats.to_a[1..-1].map { |b| b[4].first.to_i }
    end
  end
end
