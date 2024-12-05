require 'bundler/setup'
require 'active_support/all'

class CeresSearch
  def initialize(input)
    @field = input.split("\n")
    @height = @field.length
    @width = @field[0].length
    @directions = [
      [1, 1],   # down-right
      [1, -1],  # down-left
      [-1, 1],  # up-right
      [-1, -1]  # up-left
    ]
    @mas_locations = Hash.new(0)
  end

  def count_xmases
    count("MAS")
    @mas_locations.count { |_, count| count > 1 }
  end

  private

  def count(word)
    @mas_locations.clear
    @height.times do |y|
      @width.times do |x|
        @directions.each do |direction|
          check_direction(word, x, y, direction)
        end
      end
    end
  end

  def check_direction(word, start_x, start_y, direction)
    # Early return if word cannot fit in the grid
    return unless can_fit?(start_x, start_y, word, direction)

    a_location = nil
    word.each_char.with_index do |char, index|
      ny = start_y + index * direction[0]
      nx = start_x + index * direction[1]

      return unless @field[ny][nx] == char
      a_location = "#{ny},#{nx}" if char == 'A'
    end

    @mas_locations[a_location] += 1 if a_location
  end

  def can_fit?(start_x, start_y, word, direction)
    end_y = start_y + (word.length - 1) * direction[0]
    end_x = start_x + (word.length - 1) * direction[1]

    end_y.between?(0, @height - 1) &&
      end_x.between?(0, @width - 1)
  end
end

filename = ARGV[0]
search = CeresSearch.new(File.read(File.expand_path(filename, __dir__)))
puts search.count_xmases