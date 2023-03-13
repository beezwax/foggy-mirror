# frozen_string_literal: true

require "spec_helper"
require "foggy-mirror"

describe FoggyMirror::CSS do
  subject { described_class.new(processor) }

  let(:processor) {
    double(FoggyMirror::Processor, base_color: '#000000', blobs: [
      FoggyMirror::Blob.new(x: 0, y: 0, r: 1, color: '#FFFFFF'),
      FoggyMirror::Blob.new(x: 1, y: 0, r: 1, color: '#FFFFFF'),
      FoggyMirror::Blob.new(x: 0, y: 1, r: 1, color: '#FFFFFF'),
      FoggyMirror::Blob.new(x: 1, y: 1, r: 1, color: '#FFFFFF')
    ])
  }

  describe "#render" do
    context 'when requesting a string' do
      it do
        expect(subject.render).to \
          match(/background-color: #000000;\nbackground-image: (?:radial-gradient\(circle at \d+% \d+%, #[0-9A-F]{3,6} 0%, #[0-9A-F]{8} \d+%\)(?:, )?){4};/)
      end
    end

    context 'when requesting a hash' do
      it {
        expect(subject.render(hash: true)).to match(
          'background-color' => '#000000',
          'background-image' => /(?:radial-gradient\(circle at \d+% \d+%, #[0-9A-F]{3,6} 0%, #[0-9A-F]{8} \d+%\)(?:, )?){4}/
        )
      }
    end
  end
end
