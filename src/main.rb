#!/usr/bin/env ruby

require 'flingsolver'

flingsolver = FlingSolver.new

# Command-line arguments check - load from console if no file specified
if ARGV.length == 0
  flingsolver.load_board_from_console
else
  # Load specified input file
  begin
    flingsolver.load_board_from_file(*ARGV)
  rescue StandardError => e
    puts e
    puts e.backtrace
    puts 'Exiting...'
    exit
  end
end

puts "Solving..."
tick = Time.new

flingsolver.generate_game_tree
flingsolver.find_solved_boards
flingsolver.find_solutions
flingsolver.print_solutions

tock = Time.new
puts "Done! Time taken #{tock - tick} seconds"