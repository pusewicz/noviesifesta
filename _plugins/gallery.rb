require 'fastimage'

module Gallery
  class Image
    def initialize(src)
      @src = src
    end

    def path
      @src
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

    #def generate_thumbnail
      #return if File.exist?(thumbnail_path)
      #thumb_version thumbnail_path
    #end
  end

  class Generator < Jekyll::Generator
    def generate(site)
      index = site.pages.detect { |page| page.name == 'index.html' }
      index.data['gallery'] = gallery(site)
    end

    private

    def gallery(site)
      root = site.config["source"]
      files = Dir['images/gallery/**/*.jpg'].delete_if { |i| i =~ /thumb/ }.map { |i| Image.new(i) }
      raise "No files in #{root}" if files.empty?
      files
    end
  end
end
