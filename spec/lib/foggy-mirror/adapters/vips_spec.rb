# frozen_string_literal: true

require "spec_helper"
require "foggy-mirror"

describe FoggyMirror::Vips do
  subject { described_class.new('img/unsplash-sq.webp') }

  describe "#dominant_color" do
    it { expect(subject.dominant_color).to match([80..85, 83..87, 85..89]) }
  end

  describe "#color_samples" do
    it { expect(subject.color_samples(2)).to match([[0..255, 0..255, 0..255]] * 4) }
  end
end
