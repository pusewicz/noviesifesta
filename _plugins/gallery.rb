require 'fastimage'

module Gallery
  class Image
    include Vips::Process
    include Vips::Process::Resize
    include Vips::Process::Quality

    attr_reader :path, :src, :dst

    def initialize(path)
      @path = path
      generate_thumbnail
    end

    def src
      path
    end

    def dst
      thumbnail_path
    end

    def size
      @size ||= FastImage.size(path).join('x')
    end

    def name
      File.basename(path).split(/-|_/).first
    end

    def manufacturer
      parts = File.dirname(path).split('/')
      [parts[2], parts[3]].compact.join(' ')
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
        'alt' => alt
      }
    end

    private

    def generate_thumbnail
      resize_to_fit(92, 120).process!
    end

    def image
      @image ||= EasyImage.new(path, 'image/jpeg')
    end
  end

  class Generator < Jekyll::Generator
    def generate(site)
      index = site.pages.detect { |page| page.name == 'index.html' }
      index.data['gallery'] = gallery
    end

    private

    def gallery
      Dir['images/gallery/**/*.jpg'].map { |i| Image.new(i) }
    end
  end
end
