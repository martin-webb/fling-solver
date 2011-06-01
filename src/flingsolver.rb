require 'board'

class FlingSolver

  BOARD_HEIGHT = 8
  BOARD_WIDTH = 7

  def initialize
    @root_board = nil
    @solved_boards = []
    @solutions = {}
  end
  
  
  def load_board_from_file(file_path)
    lines = IO.readlines(file_path)
    grid = []
    
    lines.each do |line|
      grid_row = []
      
      line.chomp.chars.each do |char|
        grid_row << (char == '1' ? 1 : 0)
      end
      
      grid << grid_row
    end
    
    # Check consistency of grid - all rows should be the same length as the first
    initial_row_length = grid[0].length
    
    grid.each do |row|
      raise 'Inconsistent row lengths in root board grid - check input file' if row.length != initial_row_length
    end
    
    @root_board = Board.new(grid)
  end
  
  
  def load_board_from_console
    grid = []
    
    BOARD_HEIGHT.times do |row|
      grid_row = []
      
      print "Row #{row + 1}: "
      line = gets
      line.chomp!
      
      BOARD_WIDTH.times do |col|
        grid_row << (!line[col].nil? && line[col].chr =~ /\S/ ? 1 : 0)
      end
      
      grid << grid_row
    end
    
    @root_board = Board.new(grid)
    @root_board.draw
  end
  
  
  def generate_game_tree
    @root_board.generate_children
    puts "#{Board.count} boards generated"
  end
  
  
  def find_solved_boards
    @root_board.check_for_solution(@solved_boards)
    puts "#{@solved_boards.length} solutions found"
  end
  
  
  def find_solutions
    @solutions.clear
    
    @solved_boards.each do |solved_board|
      solution = []
      
      # Move back upwards the tree adding each board to the FRONT of the array 
      current_board = solved_board
      until current_board.parent_board.nil?
        solution.push(current_board)
        current_board = current_board.parent_board
      end
      
      # Create new array in hash for solutions of length 'n' if required
      @solutions[solution.length] = [] if !@solutions.has_key?(solution.length)
      
      # Add solution to array in hash under key of the solutions length
      @solutions[solution.length] << solution
    end
    
    @solutions.each do |key, value|
      puts "  #{value.length} solutions with #{key} steps"
    end
  end
  
  
  def print_solutions
    # Get lowest step count for solutions i.e. most efficient
    lowest_step_count = @solutions.keys.min
    
    puts 'Showing lowest step solutions:'
    i = 1
    
    # Print each solution
    @solutions[lowest_step_count].each do |solution|
      puts "  Solution #{i}:"
      
      # Draw starting board
      @root_board.draw
      
      # Print each step from the solution
      solution.reverse.each do |board|
        puts "Move: #{board.move}"
        board.draw
      end
      i += 1
      puts
    end
  end
  
end