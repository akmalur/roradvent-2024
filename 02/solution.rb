require 'bundler/setup'
require 'active_support/all'

class RedNoseReport

  attr_reader :levels, :is_safe, :direction, :reason
  def initialize(report, errors = 0)
    @levels = report
    @is_safe = nil
    @direction = nil
    @reason = nil
    @errors = errors

    puts "Checking report: #{@levels}"
    check_levels(@levels)
    puts "Report is safe: #{@is_safe} :: #{@reason} :: #{@errors}"
  end

  def clone_report(index, errors)
    levels = @levels.dup
    levels.delete_at(index)
    return RedNoseReport.new(levels, errors)
  end

  def clean_report
    @levels.each_index do |index|
      levels = @levels.dup
      levels.delete_at(index)
      report = RedNoseReport.new(levels, @errors + 1)
      if report.is_safe
        @is_safe = true
        @direction = :clean
        @reason = "Safe report found"
        return
      end
    end

    @is_safe = false
    @reason = "No safe report found"
    @direction = :dirty
  end

  def check_levels(levels, direction = nil, safe = nil, index = 0)
    head, *tail = levels
    if tail.empty?
      @is_safe = safe
      @direction = direction
      return
    end

    diff = tail.first - head

    direction = check_direction(direction, diff)

    if direction == :neither
      if @errors == 0
        puts "Cleaning at index #{index} due to direction #{direction}"
        return clean_report
      end

      @is_safe = false
      @direction = direction
      @reason = "Direction is neither ascending nor descending"
      return
    end

    if (1..3).include?(diff.abs)
      safe = [:ascending, :descending].include?(direction)
      return check_levels(tail, direction, safe, index + 1)
    end

    if @errors == 0
      puts "Cleaning at index #{index} due to diff #{diff}"
      return clean_report
    end

    @is_safe = false
    @direction = direction
    @reason = "Difference is #{diff.abs}"
    puts "Report is not safe: #{@reason}"
  end

  def check_direction(direction, diff)
    if direction.nil?
      return :ascending if diff > 0
      return :descending if diff < 0
      return :neither if diff == 0
    elsif direction == :ascending && diff <= 0
      return :neither
    elsif direction == :descending && diff >= 0
      return :neither
    else
      direction
    end
  end
end

reports = []

filename = ARGV[0]
File.open(File.expand_path(filename, __dir__)).each_line do |input|
  reports << RedNoseReport.new(input.strip.split.map(&:to_i))
end

result = 0
reports.each do |report|
  #puts "#{report.levels} :: #{report.is_safe} --- #{report.direction} --- #{report.reason}" unless report.is_safe
  result += 1 if report.is_safe
end

puts "Safe reports: #{result}"
puts "Total reports: #{reports.size}"
puts "DONE"