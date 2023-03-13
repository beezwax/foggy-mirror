# frozen_string_literal: true

module FoggyMirror
  class SVG < Exporter
    XML_HEADER = '<?xml version="1.0" encoding="UTF-8"?>'

    ID_START = 'a'

    VIEWBOX_SIZE = 1000

    STRATEGIES = %i[embedded_image gradients]

    def render(strategy: STRATEGIES.first)
      strategy = STRATEGIES.first if strategy.nil?

      unless STRATEGIES.include?(strategy.to_sym)
        raise ArgumentError, "Invalid SVG rendering strategy `#{strategy}'"
      end

      send("render_#{strategy}")
    end

    def render_gradients
      "#{header}<defs>#{radial_gradients.join}</defs>#{circles.join}</svg>"
    end

    def render_embedded_image
      "#{header}#{blur_filter}#{embedded_image}</svg>"
    end

    def header
      %{#{XML_HEADER}<svg width="#{VIEWBOX_SIZE}" height="#{VIEWBOX_SIZE}" preserveAspectRatio="none" viewBox="0 0 #{VIEWBOX_SIZE} #{VIEWBOX_SIZE}" xmlns="http://www.w3.org/2000/svg" version="1.1" style="background-color:#{base_color}">}
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

    private

    def blur_filter
      <<~FILTER.lines.map(&:strip).join
        <filter id="b" color-interpolation-filters="sRGB">
          <feGaussianBlur in="SourceGraphic" stdDeviation="30"/>
          <feComponentTransfer>
            <feFuncA type="discrete" tableValues="1 1"/>
          </feComponentTransfer>
        </filter>
      FILTER
    end

    def embedded_image
      %{<image href="#{data_uri}" width="#{VIEWBOX_SIZE}" height="#{VIEWBOX_SIZE}" filter="url(#b)"/>}
    end
  end
end
