# frozen_string_literal: true

module FoggyMirror
  class Color
    RGB_WEIGHTS = [0.299, 0.587, 0.114].freeze

    PADDED_RGB_HEX = '%06x'

    def initialize(color)
      if color.kind_of?(String)
        color = color[/[A-Z0-9]{6}/i].to_i(16)
      elsif color.kind_of?(Array)
        color = (color[0] << 16) + (color[1] << 8) + color[2]
      end

      color = color.to_i

      if color > 0xFFFFFF || color < 0
        raise ArgumentError, "out of range color value (#{color < 0 ? '-' : ''}0x#{color.abs.to_s(16).upcase})"
      end

      @value = color.to_i
    end

    def brightness(weights: RGB_WEIGHTS)
      Math.sqrt(
        weights[0] * red ** 2 +
        weights[1] * green ** 2 +
        weights[2] * blue ** 2
      ).to_i
    end

    def red
      (@value & 0xFF0000) >> 16
    end

    def green
      (@value & 0x00FF00) >> 8
    end

    def blue
      @value & 0x0000FF
    end

    def ==(oth)
      oth.to_i == @value
    end
    alias_method :eql?, :==

    def hash
      @value.hash
    end

    def to_s(prefix: '#', shorthand: true)
      if shorthand
        return 'red' if @value == 0xFF0000

        if (@value & 0xF0F0F0) == (@value & 0x0F0F0F) << 4
          hex = to_s(prefix: '', shorthand: false)
          return prefix.to_s + hex[0] + hex[2] + hex[4]
        end
      end

      prefix.to_s + (PADDED_RGB_HEX % @value).upcase
    end

    def to_i
      @value
    end

    def inspect
      "#<#{self.class.name} #{to_s}>"
    end
  end
end
