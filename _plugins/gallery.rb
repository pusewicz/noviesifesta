require 'fastimage'
require 'vips'
require 'vips-process'
require 'vips-process/resize'
require 'vips-process/quality'
require 'vips-process/base'

module Gallery
  class Image < Vips::Process::Base
    include Vips::Process
    include Vips::Process::Resize
    include Vips::Process::Quality

    attr_reader :path

    version(:thumb)   { resize_to_fit(92, 120) }

    def initialize(*)
      super
      generate_thumbnail
    end

    def path
      src
    end

    def size
      @size ||= FastImage.size(path).join('x')
    end

    def name
      File.basename(path).split(/-|_/).first.capitalize
    end

    def manufacturer
      parts = File.dirname(path).split('/')
      [parts[2], parts[3]].compact.join(' ').gsub('-', ' ').gsub(/\b(?<!['â`])[a-z]/) { $&.capitalize }
    end

    def alt
      "Vestido de Novia #{manufacturer} - Modelo #{name}"
    end

    def thumbnail_path
      path.sub('.', '_thumb.')
    end

    def to_liquid(*)
      {
        'path' => path,
        'size' => size,
        'name' => name,
        'alt' => alt,
        'thumbnail_path' => thumbnail_path
      }
    end

    private

    def generate_thumbnail
      return if File.exist?(thumbnail_path)
      puts "Generating #{thumbnail_path}..."
      thumb_version thumbnail_path
    end
  end

  class Generator < Jekyll::Generator
    def generate(site)
      index = site.pages.detect { |page| page.name == 'index.html' }
      index.data['gallery'] = gallery
    end

    private

    def gallery
      Dir['images/gallery/**/*.jpg'].delete_if { |i| i =~ /thumb/ }.map { |i| Image.new(i) }
    end
  end
end
