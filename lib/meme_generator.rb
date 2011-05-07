require "rubygems"
require "bundler/setup"
require "RMagick"

class MemeGenerator
  VERSION = "0.0.2"
  IMPACT_PATH = "fonts/Impact.ttf" # If you don't have OS X, fork me :)

  class << self
    def run(argv = ARGV)
      generator, top, bottom = argv[0..2]

      return list_generators if generator == "--list"
      return usage unless generator && (top || bottom)

      if path = generators.find { |p| p =~ generator}
        generate(path, top, bottom)
        exit 0
      else
        puts "Meme not found"
        exit 1
      end
    end

    private

    def usage
      puts 'usage: memegen <generator> <top text> <bottom text> [--list]'
      exit 1
    end

    def list_generators
      generators.each do |path|
        puts File.basename(path).gsub(/\..*/, '')
      end
      exit 0
    end

    def generate(path, top, bottom)
      top = top.upcase
      bottom = bottom.upcase

      canvas = Magick::ImageList.new(path)
      image = canvas.first

      draw = Magick::Draw.new
      draw.font = IMPACT_PATH if File.exists?(IMPACT_PATH)
      draw.font_weight = Magick::BoldWeight

      pointsize = image.columns / 5.0
      stroke_width = pointsize / 30.0
      x_position = image.columns / 2
      y_position = image.rows * 0.15

      # Draw top
      unless top.empty?
        scale, text = scale_text(top)
        bottom_draw = draw.dup
        bottom_draw.annotate(canvas, 0, 0, 0, 0, text) do
          self.interline_spacing = -(pointsize / 5)
          self.stroke_antialias(true)
          self.stroke = "black"
          self.fill = "white"
          self.gravity = Magick::NorthGravity
          self.stroke_width = stroke_width * scale
          self.pointsize = pointsize * scale
        end
      end

      # Draw bottom
      unless bottom.empty?
        scale, text = scale_text(bottom)
        bottom_draw = draw.dup
        bottom_draw.annotate(canvas, 0, 0, 0, 0, text) do
          self.interline_spacing = -(pointsize / 5)
          self.stroke_antialias(true)
          self.stroke = "black"
          self.fill = "white"
          self.gravity = Magick::SouthGravity
          self.stroke_width = stroke_width * scale
          self.pointsize = pointsize * scale
        end
      end

      output_path = "/tmp/meme-#{Time.now.to_i}.jpeg"
      canvas.write(output_path)
      puts output_path
      exit 0
    end

    def word_wrap(txt, col = 80)
      txt.gsub(/(.{1,#{col + 4}})(\s+|\Z)/, "\\1\n")
    end

    def scale_text(text)
      text = text.dup
      if text.length < 10
        scale = 1.0
      elsif text.length < 24
        text = word_wrap(text, 10)
        scale = 0.70
      else
        text = word_wrap(text, 18)
        scale = 0.5
      end
      [scale, text.strip]
    end

    def generators
      home_dir = File.expand_path("~")
      Dir.glob(["generators/*", home_dir]).sort
    end
  end
end