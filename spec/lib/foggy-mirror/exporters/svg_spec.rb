# frozen_string_literal: true

require "spec_helper"
require "foggy-mirror"
require "nokogiri"

describe FoggyMirror::SVG do
  subject { described_class.new(processor) }

  let(:processor) {
    double(FoggyMirror::Processor, base_color: '#000000', blobs: [
      FoggyMirror::Blob.new(x: 0, y: 0, r: 1, color: '#FFFFFF'),
      FoggyMirror::Blob.new(x: 1, y: 0, r: 1, color: '#FFFFFF'),
      FoggyMirror::Blob.new(x: 0, y: 1, r: 1, color: '#000000'),
      FoggyMirror::Blob.new(x: 1, y: 1, r: 1, color: '#000000')
    ])
  }

  describe "#render" do
    let(:xml) { Nokogiri::XML(subject.render) }

    it { expect(xml.errors).to be_empty }
    it { expect(xml.root.name).to eq('svg') }
    it { expect(xml.root.namespace.href).to eq('http://www.w3.org/2000/svg') }
    it { expect(xml.root[:viewBox]).to eq('0 0 1000 1000') }
    it { expect(xml.root[:style]).to match(/background-color: ?#[0-9A-F]{6};?/) }
    it { expect(xml.css('defs radialGradient').length).to eq(2) }
    it { expect(xml.css('circle').length).to eq(4) }
  end
end
