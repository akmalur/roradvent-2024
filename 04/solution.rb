require 'bundler/setup'
require 'active_support/all'

class CeresSearch

  attr_reader :field
  def initialize(input)
    @field = input.split("\n")
    @y = @field.length
    @x = @field[0].length
    @directions = [
      [1, 1], # down-right
      [1, -1], # down-left
      [-1, 1], # up-right
      [-1, -1] # up-left
    ]
    @mases = {}
  end


  def count(word)
    count = 0
    @y.times do |y|
      @x.times do |x|
        @directions.each do |direction|
          count += check_direction(word, x, y, direction)
        end
      end
    end
    count
  end

  def count_xmases
    count("MAS")
    @mases.count { |k, v| v > 1 }
  end

  def check_direction(word, x, y, direction)
    a = 0
    word.each_char.with_index do |char, index|
      ny, nx = y + index * direction[0], x + index * direction[1]
      return 0 if out_of_bounds?(ny, nx) || @field[ny][nx] != char
      if @field[ny][nx] == 'A'
        a = "#{ny},#{nx}"
      end
    end
    @mases[a] ||= 0
    @mases[a] += 1
    return 1
  end

  def out_of_bounds?(y, x)
    y < 0 || y >= @y || x < 0 || x >= @x
  end
end

filename = ARGV[0]
search = CeresSearch.new(File.read(File.expand_path(filename, __dir__)))

puts search.count_xmases