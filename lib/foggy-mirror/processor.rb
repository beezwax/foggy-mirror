# frozen_string_literal: true

module FoggyMirror
  class Processor
    attr_reader :image_path, :resolution, :overlap, :random_offset, :random

    def initialize(image_path, resolution: DEFAULT_RESOLUTION, overlap: 0.5, distribution: :shuffle, random_offset: 0.5, random: Random.new, adapter: ImageMagick, adapter_options: {})
      @image_path = image_path

      @resolution = resolution
      @overlap = overlap
      @distribution = distribution
      @random_offset = random_offset

      @random = random
      @adapter = adapter.new(image_path, **adapter_options)
    end

    def base_color
      @base_color ||= @adapter.dominant_color
    end

    def color_samples(res)
      @color_samples ||= @adapter.color_samples(res)
    end

    def to_css(hash: false)
      CSS.new(self).render(hash: hash)
    end

    def to_svg
      SVG.new(self).render
    end

    def blobs
      samples = color_samples(resolution)

      increment = 1.0 / (resolution - 1)

      blobs = resolution.times.with_object([]) do |y, blobs|
        resolution.times do |x|
          xp = x * increment + increment * random_offset * (random.rand - 0.5)
          yp = y * increment + increment * random_offset * (random.rand - 0.5)
          r = increment * (1 + overlap)
          color = samples[y * resolution + x]

          blobs << Blob.new(x: xp, y: yp, r: r, color: color)
        end
      end

      case @distribution.to_s.downcase
      when 'shuffle'
        blobs.shuffle(random: random)
      when 'spiral_in'
        spiral_in(blobs)
      when 'spiral_out'
        spiral_in(blobs).reverse
      when 'scan_up'
        blobs.reverse
      else
        blobs
      end
    end

    private

    def spiral_in(array)
      matrix = array.each_slice(Math.sqrt(array.size).to_i).to_a

      actions = [
        -> { matrix.shift                       }, # top
        -> { matrix.map { |f| f.pop }           }, # right
        -> { matrix.pop.reverse                 }, # bottom
        -> { matrix.map { |f| f.shift }.reverse }  # left
      ]

      peel = actions.cycle

      [].tap do |r|
        r.concat(peel.next.call) until matrix.empty?
      end
    end
  end
end
