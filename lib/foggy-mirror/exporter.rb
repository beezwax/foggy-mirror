# frozen_string_literal: true

require 'forwardable'

module FoggyMirror
  class Exporter
    extend Forwardable

    def_delegators :@processor, :base_color, :resolution, :blobs

    def initialize(processor)
      @processor = processor
    end

    def render
      raise NotImplementedError
    end
  end
end
