# frozen_string_literal: true

require 'forwardable'

module FoggyMirror
  class Exporter
    extend Forwardable

    def_delegators :@processor, :base_color, :resolution, :blobs, :data_uri

    def initialize(processor)
      @processor = processor
    end

    def render
      raise NoMethodError
    end
  end
end
