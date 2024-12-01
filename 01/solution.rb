require 'bundler/setup'
require 'active_support/all'

class HistorianHysteria
  def initialize(input)
    @left = []
    @left_map = {}
    @right = []
    @right_map = {}
    process input
    sort
  end

  def process(input)
    input.split.each_with_index do |value, index|
      number = value.to_i
      if index.even?
        @left << number
        @left_map.has_key?(number) ? @left_map[number] += 1 : @left_map[number] = 1
      else
        @right << number
        @right_map.has_key?(number) ? @right_map[number] += 1 : @right_map[number] = 1
      end
    end
  end

  def sort
    @left = @left.sort
    @right = @right.sort
  end

  def distance
    result = 0
    @left.each_with_index do |value, index|
      result += (value - @right[index]).abs
    end
    result
  end

  def similarity
    result = 0
    @left.each do |value|
      result += value * (@right_map[value] || 0)
    end
    result
  end
end

filename = ARGV[0]
file = File.read(File.expand_path(filename, __dir__))
hh = HistorianHysteria.new(file)
puts hh.distance
puts hh.similarity
puts "DONE"