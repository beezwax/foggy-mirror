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
    let(:xml) { Nokogiri::XML(subject.render(strategy: strategy)) }

    context "with strategy: :embedded_images" do
      let(:strategy) { :embedded_image }
      let(:data_uri) { "data:image/gif;base64,AAA" }

      before do
        allow(processor).to receive(:data_uri).and_return(data_uri)
      end

      it { expect(xml.errors).to be_empty }
      it { expect(xml.root.name).to eq('svg') }
      it { expect(xml.root.namespace.href).to eq('http://www.w3.org/2000/svg') }
      it { expect(xml.root[:viewBox]).to eq('0 0 1000 1000') }
      it { expect(xml.root[:width].to_i).to eq(1000) }
      it { expect(xml.root[:height].to_i).to eq(1000) }
      it { expect(xml.root[:preserveAspectRatio]).to eq('none') }
      it { expect(xml.root[:style]).to match(/background-color: ?#[0-9A-F]{6};?/) }

      it { expect(xml.css('filter feGaussianBlur').length).to eq(1) }
      it { expect(xml.css('image').length).to eq(1) }
    end

    context "with strategy: gradients" do
      let(:strategy) { :gradients }

      it { expect(xml.errors).to be_empty }
      it { expect(xml.root.name).to eq('svg') }
      it { expect(xml.root.namespace.href).to eq('http://www.w3.org/2000/svg') }
      it { expect(xml.root[:viewBox]).to eq('0 0 1000 1000') }
      it { expect(xml.root[:width].to_i).to eq(1000) }
      it { expect(xml.root[:height].to_i).to eq(1000) }
      it { expect(xml.root[:preserveAspectRatio]).to eq('none') }
      it { expect(xml.root[:style]).to match(/background-color: ?#[0-9A-F]{6};?/) }

      it { expect(xml.css('defs radialGradient').length).to eq(2) }
      it { expect(xml.css('circle').length).to eq(4) }
    end

  end
end
