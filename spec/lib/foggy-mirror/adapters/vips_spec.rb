# frozen_string_literal: true

require "spec_helper"
require "foggy-mirror"

describe FoggyMirror::Vips do
  subject { described_class.new('img/unsplash-sq.webp') }

  describe "#dominant_color" do
    it { expect(subject.dominant_color).to match(/\A#5[012]5[456]5[678]\Z/) }
  end

  describe "#color_samples" do
    it { expect(subject.color_samples(2)).to match([/#[0-9A-F]{6}/] * 4) }
  end
end
