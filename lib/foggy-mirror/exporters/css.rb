# frozen_string_literal: true

module FoggyMirror
  class CSS < Exporter
    # If hash is true it returns a Ruby Hash with the CSS properties instead of
    # a CSS-ready string
    #
    def render(hash: false)
      if hash
        return {
          'background-color' => base_color,
          'background-image' => radial_gradients.join(', ')
        }
      end

      render(hash: true).map { |k, v| "#{k}: #{v}" }.join(";\n") + ';'
    end

    private

    def radial_gradients
      blobs.map do |b|
        x, y, r = [b.x, b.y, b.r].map { |c| (c * 100).round(1) }
        "radial-gradient(circle at #{x}% #{y}%, #{b.color} 0%, #{b.color.to_s(shorthand: false)}00 #{r}%)"
      end
    end
  end
end
