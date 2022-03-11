# frozen_string_literal: true

require "spec_helper"
require "foggy-mirror"

describe FoggyMirror::Processor do
  let(:dummy_adapter) { double(:adapter, dominant_color: "#FFFFFF") }
  let(:dummy_random) { double(Random) }

  let(:instance) {
    described_class.new('foo', resolution: 10, overlap: 0.42,
                               random_offset: 0.42, random: dummy_random)
  }

  describe "#initialize" do
    it { expect(instance.image_path).to eq('foo') }
    it { expect(instance.resolution).to eq(10) }
    it { expect(instance.overlap).to eq(0.42) }
    it { expect(instance.random_offset).to eq(0.42) }
    it { expect(instance.random).to eq(dummy_random) }

    it { expect(described_class.new('foo', adapter: :magick).adapter).to be_a(FoggyMirror::ImageMagick) }
    it { expect(described_class.new('foo', adapter: :vips).adapter).to be_a(FoggyMirror::Vips) }
    it { expect(described_class.new('foo', adapter: FoggyMirror::ImageMagick).adapter).to be_a(FoggyMirror::ImageMagick) }
    it { expect(described_class.new('foo', adapter: FoggyMirror::Vips).adapter).to be_a(FoggyMirror::Vips) }
    it { expect { described_class.new('foo', adapter: :idontknowthatone) }.to raise_error(KeyError) }
  end

  describe "#base_color" do
    before do
      allow(instance).to receive(:adapter).and_return(dummy_adapter)
    end

    it { expect(instance.base_color).to eq('#FFFFFF') }
  end

  describe "#color_samples" do
    let(:samples_2x2) { %w[#FF0000 #00FF00 #0000FF #FFFF00] }
    let(:instance) { described_class.new('foo', resolution: 2) }

    before do
      allow(dummy_adapter).to receive(:color_samples).with(2).and_return(samples_2x2)
      allow(instance).to receive(:adapter).and_return(dummy_adapter)
    end

    it { expect(instance.color_samples(2)).to eq(samples_2x2) }
  end

  describe "#blobs" do
    let(:samples_2x2) { %w[#000001 #000002 #000003 #000004] }
    let(:samples_3x3) { %w[#000001 #000002 #000003 #000004 #000005 #000006 #000007 #000008 #000009] }

    before do
      allow(dummy_adapter).to receive(:color_samples).with(2).and_return(samples_2x2)
      allow(dummy_adapter).to receive(:color_samples).with(3).and_return(samples_3x3)
      allow(instance).to receive(:adapter).and_return(dummy_adapter)
    end

    context 'with default (scan) distribution' do
      let(:instance) { described_class.new('foo', resolution: 2, overlap: 0, random_offset: 0) }

      it {
        expect(instance.blobs).to eq([
          FoggyMirror::Blob.new(x: 0.0, y: 0.0, r: 1.0, color: '#000001'),
          FoggyMirror::Blob.new(x: 1.0, y: 0.0, r: 1.0, color: '#000002'),
          FoggyMirror::Blob.new(x: 0.0, y: 1.0, r: 1.0, color: '#000003'),
          FoggyMirror::Blob.new(x: 1.0, y: 1.0, r: 1.0, color: '#000004')
        ])
      }
    end

    context 'with scan_reverse distribution' do
      let(:instance) { described_class.new('foo', resolution: 2, overlap: 0, random_offset: 0, distribution: :scan_reverse) }

      it {
        expect(instance.blobs).to eq([
          FoggyMirror::Blob.new(x: 1.0, y: 1.0, r: 1.0, color: '#000004'),
          FoggyMirror::Blob.new(x: 0.0, y: 1.0, r: 1.0, color: '#000003'),
          FoggyMirror::Blob.new(x: 1.0, y: 0.0, r: 1.0, color: '#000002'),
          FoggyMirror::Blob.new(x: 0.0, y: 0.0, r: 1.0, color: '#000001')
        ])
      }
    end

    context 'with spiral_in distribution' do
      let(:instance) { described_class.new('foo', resolution: 3, overlap: 0, random_offset: 0, distribution: :spiral_in) }

      it {
        expect(instance.blobs).to eq([
          FoggyMirror::Blob.new(x: 0.0, y: 0.0, r: 0.5, color: '#000001'),
          FoggyMirror::Blob.new(x: 0.5, y: 0.0, r: 0.5, color: '#000002'),
          FoggyMirror::Blob.new(x: 1.0, y: 0.0, r: 0.5, color: '#000003'),
          FoggyMirror::Blob.new(x: 1.0, y: 0.5, r: 0.5, color: '#000006'),
          FoggyMirror::Blob.new(x: 1.0, y: 1.0, r: 0.5, color: '#000009'),
          FoggyMirror::Blob.new(x: 0.5, y: 1.0, r: 0.5, color: '#000008'),
          FoggyMirror::Blob.new(x: 0.0, y: 1.0, r: 0.5, color: '#000007'),
          FoggyMirror::Blob.new(x: 0.0, y: 0.5, r: 0.5, color: '#000004'),
          FoggyMirror::Blob.new(x: 0.5, y: 0.5, r: 0.5, color: '#000005')
        ])
      }
    end

    context 'with spiral_out distribution' do
      let(:instance) { described_class.new('foo', resolution: 3, overlap: 0, random_offset: 0, distribution: :spiral_out) }

      it {
        expect(instance.blobs).to eq([
          FoggyMirror::Blob.new(x: 0.5, y: 0.5, r: 0.5, color: '#000005'),
          FoggyMirror::Blob.new(x: 0.0, y: 0.5, r: 0.5, color: '#000004'),
          FoggyMirror::Blob.new(x: 0.0, y: 1.0, r: 0.5, color: '#000007'),
          FoggyMirror::Blob.new(x: 0.5, y: 1.0, r: 0.5, color: '#000008'),
          FoggyMirror::Blob.new(x: 1.0, y: 1.0, r: 0.5, color: '#000009'),
          FoggyMirror::Blob.new(x: 1.0, y: 0.5, r: 0.5, color: '#000006'),
          FoggyMirror::Blob.new(x: 1.0, y: 0.0, r: 0.5, color: '#000003'),
          FoggyMirror::Blob.new(x: 0.5, y: 0.0, r: 0.5, color: '#000002'),
          FoggyMirror::Blob.new(x: 0.0, y: 0.0, r: 0.5, color: '#000001')
        ])
      }
    end
  end

  describe "#to_svg" do
    before do
      allow_any_instance_of(FoggyMirror::SVG).to receive(:render).and_return('<svg/>')
    end

    it { expect(instance.to_svg).to eq('<svg/>') }
  end

  describe "#to_css" do
    before do
      allow_any_instance_of(FoggyMirror::CSS).to receive(:render).and_return('css')
      allow_any_instance_of(FoggyMirror::CSS).to receive(:render).with(hash: true).and_return({ css: true })
    end

    it { expect(instance.to_css).to eq('css') }
    it { expect(instance.to_css(hash: true)).to eq({ css: true }) }
  end
end
