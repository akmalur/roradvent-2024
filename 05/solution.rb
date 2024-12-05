require 'bundler/setup'
require 'active_support/all'

class PrintQueue
  def self.is_a_rule(str)
    str =~ /^\d+\|\d+$/
  end

  def self.is_an_update(str)
    str =~ /^(\d+,)*\d+$/
  end

  attr_reader :rules, :updates

  def initialize(rules, updates)
    @rules = {}
    rules.each do |rule|
      rule.split('|').each do |r|
        if !@rules.key?(r.to_i)
          @rules[r.to_i] = []
        end
        @rules[r.to_i] << rule.split('|').map(&:to_i)
      end
    end

    @updates = []
    updates.each_with_index do |update, index|
      @updates[index] = update.split(',').map(&:to_i).flatten
    end
  end

  def find_valid_updates()
    valid_updates = []
    @updates.each do |update|
      valid = true
      update.each do |u|
        violations = rule_check(update, @rules[u]) if @rules.key?(u)
        valid = false unless violations&.empty?
      end
      valid_updates << update if valid
    end
    valid_updates.uniq
  end

  def find_invalid()
    invalid_updates = {}
    @updates.each do |update|
      update.each do |u|
        violations = rule_check(update, @rules[u]) if @rules.key?(u)
        if violations&.any?
          unless invalid_updates.key?(update)
            invalid_updates[update] = []
          end
          invalid_updates[update] << violations
        end
      end
    end
    return invalid_updates
  end

  def fix_violations(violations, update)
    while violations.any?
      violations.each do |violation|
        first_check = update.find_index(violation[0])
        second_check = update.find_index(violation[1])
        if first_check > second_check
          update[first_check], update[second_check] = update[second_check], update[first_check]
        end
      end
      violations = []
      update.each do |u|
        v = rule_check(update, @rules[u]) if @rules.key?(u)
        violations << v if v&.any?
      end
      violations = violations.flatten(1).uniq
    end
    return update
  end

  def rule_check(update, rules)
    result = []
    rules.each do |rule|
      first_check = update.find_index(rule[0])
      second_check = update.find_index(rule[1])
      unless first_check.nil? || second_check.nil?
        unless first_check < second_check
          result << rule
        end
      end
    end
    return result
  end

  def check()
    updates = find_valid_updates
    sum = 0
    updates.each do |update|
      sum += update[update.size/2]
    end
    sum
  end

  def fix()
    invalid_updates = find_invalid
    fixed = []
    invalid_updates.each do |iu, v|
      fixed << fix_violations(v.flatten(1).uniq, iu)
    end
    sum = 0
    fixed.each do |f|
      sum += f[f.size/2]
    end
    sum
  end
end

rules = []
updates = []


filename = ARGV[0]
File.open(File.expand_path(filename, __dir__)).each_line do |input|
  if PrintQueue.is_a_rule(input)
    rules << input
  elsif PrintQueue.is_an_update(input)
    updates << input
  end
end

pq = PrintQueue.new(rules, updates)

puts pq.fix