require 'bundler/setup'
require 'active_support/all'

patterns = {
  mul: /mul\(\d+,\d+\)/,
  do: /do\(['^)]*\)/,
  dont: /don't\([^)]*\)/
}

def extract_operations(input, patterns)
  p = /#{patterns.values.map(&:source).join('|')}/
  input.scan(p).flatten
end

def mul(operation)
  match = operation.match(/mul\((\d+),(\d+)\)/)
  return nil unless match

  x = match[1].to_i
  y = match[2].to_i
  x * y
end

filename = ARGV[0]
input = File.open(File.expand_path(filename, __dir__)).read

operations = extract_operations(input, patterns)

result = 0
dont = false

puts operations

operations.each do |operation|
  case operation
    when patterns[:mul]
      result += mul(operation) unless dont
    when patterns[:do]
      dont = false
    when patterns[:dont]
      dont = true
  end
end

puts result