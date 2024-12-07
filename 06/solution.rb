require 'bundler/setup'
require 'set'

class Field
  def initialize(input)
    @grid = input.chomp.split("\n").map(&:chars)
    @height = @grid.length
    @width = @grid[0].length
  end

  def guard_start_position
    @grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        return [y, x] if cell == '^'
      end
    end
  end

  def path_length(start_pos, initial_direction = [-1, 0])
    visited = Set.new
    current_pos = start_pos
    direction = initial_direction

    loop do
      return nil if visited.include?(current_pos)
      visited << current_pos

      ny, nx = [current_pos, direction].transpose.map(&:sum)
      break if ny.negative? || nx.negative? || ny >= @height || nx >= @width

      while @grid[ny][nx] == '#'
        direction = [direction[1], -direction[0]]
        ny, nx = [current_pos, direction].transpose.map(&:sum)
      end

      current_pos = [ny, nx]
    end

    return visited.length
  end

  def count_additional_obstacles
    count = 0
    guard_pos = guard_start_position

    @grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        next if cell != '.'

        @grid[y][x] = '#'
        count += 1 unless path_length(guard_pos)
        @grid[y][x] = '.'
      end
    end

    return count
  end
end

filename = ARGV[0]
field_input = File.read(File.expand_path(filename, __dir__))
field = Field.new(field_input)

puts field.path_length(field.guard_start_position)

puts field.count_additional_obstacles