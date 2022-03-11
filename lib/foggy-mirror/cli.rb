# frozen_string_literal: true
require 'optparse'

module FoggyMirror
  class CLI
    DEFAULT_EXTENSION = '.foggy.svg'

    def initialize(args = ARGV)
      @args = args.dup
    end

    def run
      @options = {}
      @extension = DEFAULT_EXTENSION
      @stdout = false
      @target_dir = nil

      parser.parse!(@args)

      # OptionParser.parse removes options from the args, so we're left with
      # filenames
      @args.each do |path|
        p = Processor.new(path, **@options)

        unless @stdout
          foggy_file = File.join(@target_dir || File.dirname(path), File.basename(path, '.*') + @extension)
          IO.write(foggy_file, p.to_svg)
        else
          puts p.to_svg
        end
      end
    end

    private

    def parser
      @parser ||=
        OptionParser.new do |opts|
          opts.banner = 'Usage: foggy-mirror [options] [--] image_file ...'

          opts.on('--res=RESOLUTION', Integer, "The output resolution (how many radial gradients per dimension, default: #{DEFAULT_RESOLUTION})") do |r|
            @options[:resolution] = r
          end

          opts.on('--overlap=OVERLAP', Float, 'How much to overlap radial gradients') do |o|
            @options[:overlap] = o
          end

          opts.on('--dist=DISTRIBUTION', %w[shuffle spiral_in spiral_out scan scan_reverse], 'Distribution strategy for radial gradients') do |d|
            @options[:distribution] = d.to_s
          end

          opts.on('--random-offset=OFFSET', Float, 'Upper limit for how much to randomly offset each radial gradient') do |r|
            @options[:random_offset] = r.to_f
          end

          opts.on('--random-seed=SEED', Integer, 'The random seed to use (for deterministic results)') do |s|
            @options[:random] = Random.new(s)
          end

          opts.on('--adapter=ADAPTER', ADAPTERS.keys, 'Which graphics library adapter to use') do |a|
            @options[:adapter] = a
          end

          opts.on('--extension=EXTENSION', String, "The extension to use for created files (default: #{DEFAULT_EXTENSION})") do |e|
            @extension = e
          end

          opts.on('--stdout', 'Output to STDOUT instead of writing to files') do
            @stdout = true
          end

          opts.on('--target-dir=DIR', String, 'Directory to write files to (defaults to same as input files)') do |d|
            @target_dir = d
          end

          opts.on_tail('-h', '--help', 'Print help') do
            puts opts
            exit
          end

          opts.on_tail("--version", "Show version") do
            require 'foggy-mirror/version'
            puts VERSION
            exit
          end
        end
    end
  end
end
