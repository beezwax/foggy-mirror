# frozen_string_literal: true
require 'vips'

module FoggyMirror
  class Vips
    include Utils

    def initialize(path)
      @path = path
    end

    def dominant_color
      html_color *color_avg(@image || image(DEFAULT_RESOLUTION))
    end

    def color_samples(res)
      image(res).to_a.flatten(1).map { |rgb| html_color *rgb }
    end

    private

    def image(res = nil)
      if @image && res && @image.width != res
        @image = nil
      end

      # We load the image as a thumbnail, shrinking it to double the resolution
      # requested, making use of libvips' shrink-on-load optimization, which
      # should be way faster than loading the entire image and shrinking.
      #
      # This optimization assumes the original image isn't more than twice as
      # wide as high, or vice-versa.
      @image ||= 
        begin
          im = ::Vips::Image.thumbnail(@path, res * 2)

          # Make the image square
          if im.width > im.height
            im = im.reduceh(im.width.to_f / im.height)
          elsif im.height > im.width
            im = im.reducev(im.height.to_f / im.width)
          end

          im.resize(res.to_f / im.width)
        end
    end

    def color_avg(image)
      image.stats.to_a[1..-1].map { |b| b[4].first.to_i }
    end
  end
end
