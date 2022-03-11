# frozen_string_literal: true

require "spec_helper"
require "foggy-mirror"

describe FoggyMirror::Utils do
  let(:test_module) do
    Module.new { extend FoggyMirror::Utils }
  end

  describe "#html_color" do
    it { expect(test_module.html_color(0, 0, 0)).to eq('#000000') }
    it { expect(test_module.html_color(255, 0, 0)).to eq('#FF0000') }
    it { expect(test_module.html_color(0, 255, 0)).to eq('#00FF00') }
    it { expect(test_module.html_color(0, 0, 255)).to eq('#0000FF') }
    it { expect(test_module.html_color(10, 10, 10)).to eq('#0A0A0A') }
  end
end
