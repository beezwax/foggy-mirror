# frozen_string_literal: true

module FoggyMirror
  class SVG < Exporter
    XML_HEADER = '<?xml version="1.0" encoding="UTF-8"?>'

    ID_START = 'a'

    VIEWBOX_SIZE = 1000

    def render
      "#{header}<defs>#{radial_gradients.join}</defs>#{circles.join}</svg>"
    end

    def header
      %{#{XML_HEADER}<svg viewBox="0 0 #{VIEWBOX_SIZE} #{VIEWBOX_SIZE}" xmlns="http://www.w3.org/2000/svg" version="1.1" style="background-color:#{base_color}">}
    end

    def radial_gradients
      color_ids.map do |color, id|
        %{<radialGradient id="#{id}"><stop offset="0" stop-color="#{color}"/><stop offset="100%" stop-color="#{color}" stop-opacity="0"/></radialGradient>}
      end
    end

    def circles
      blobs.map.with_index do |b, i|
        id = color_ids[b.color]
        x, y, r = [b.x, b.y, b.r].map { |c| (c * VIEWBOX_SIZE).to_i }
        %{<circle cx="#{x}" cy="#{y}" r="#{r}" fill="url(##{id})"/>}
      end
    end

    def color_ids
      @color_ids ||=
        begin
          id = String.new(ID_START)
          Hash[blobs.map(&:color).uniq.map { |c| [c, id.dup].tap { id.succ! } }]
        end
    end
  end
end
