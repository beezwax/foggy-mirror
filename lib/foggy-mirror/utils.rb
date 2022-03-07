# frozen_string_literal: true

module FoggyMirror
  module Utils
    PADDED_HEX_BYTE = '%02x'

    def html_color(r, g, b)
      '#' + [r, g, b].map { |c| PADDED_HEX_BYTE % c }.join.upcase
    end
  end
end
