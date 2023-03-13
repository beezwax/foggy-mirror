# frozen_string_literal: true

module FoggyMirror
  Blob = Struct.new(:x, :y, :r, :color, keyword_init: true) do
    def initialize(color:, **args)
      super color: Color.new(color), **args
    end
  end
end
