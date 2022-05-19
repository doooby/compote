#!/usr/bin/env ruby

sequence = %w[| / - \\]

5.times do |i|
  $stdout.write "#{i + 1}) "
  4.times do
    sequence.each do |char|
      $stdout.write char
      sleep 0.05
      $stdout.write "\e[1D"
    end
  end
  puts 'done'
end
