# frozen_string_literal: true
begin
  require 'vips'
rescue LoadError
  raise LoadError, "Couldn't load 'vips' library, do you have ruby-vips in your Gemfile?"
end

require 'base64'

module FoggyMirror
  class Vips
    def initialize(path)
      @path = path
    end

    def dominant_color
      color_avg(load_image(DEFAULT_RESOLUTION))
    end

    def color_samples(res)
      square_image(res).to_a.flatten(1)
    end

    # format and options are passed to Vips' #write_to_buffer.
    #
    # We use .gif as the default format as it's by far the most size-efficient
    # format for very small images. E.g. a 5x5 GIF is around 171 bytes, while
    # an equivalent PNG would be around 2780 bytes, and JPEG would be larger
    # still.
    #
    def data_uri(res, format: '.gif', options: {})
      image_type = if format.downcase.match?(/\.jpe?g/)
                     'jpeg'
                   else
                     format.downcase.match(/\.(png|gif)/)[1]
                   end

      raise(ArgumentError, 'Unsupported image format') unless image_type

      base64 = Base64.strict_encode64(square_image(res).write_to_buffer(format, **options)).chomp

      "data:image/#{image_type};base64,#{base64}"
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
