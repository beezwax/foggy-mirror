# frozen_string_literal: true

require "spec_helper"
require "foggy-mirror"

describe FoggyMirror::ImageMagick do
  subject { described_class.new('img/unsplash-sq.webp') }

  describe "#dominant_color" do
    it { expect(subject.dominant_color).to eq('#525558') }
  end

  describe "#color_samples" do
    it { expect(subject.color_samples(2)).to match([/#[0-9A-F]{6}/] * 4) }
  end
end
