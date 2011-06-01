require 'move'
require 'point'

class Board
	attr_reader :grid, :parent_board, :move
	
	@@count = 0
	
	def Board.count
	  @@count
  end
	
	
  def initialize(grid, parent_board = nil)
    raise ArgumentError, 'Grid cannot be nil' if grid.nil?
    
    @grid = grid
    @furballs = []
    @valid_moves = []
    @move = nil
    @parent_board = parent_board
    @child_boards = []

    @@count += 1

    find_furballs
    compute_valid_moves
  end
  
  
  def find_furballs
    @furballs.clear
    @grid.each_index do |row|
      @grid[row].each_index do |col|
        @furballs << Point.new(col, row) if @grid[row][col] == 1
      end
    end
  end
      
  
  def compute_valid_moves           
    @valid_moves.clear
    @furballs.each do |furball|
      x = furball.x
      y = furball.y
      furball_position = Point.new(x, y) # Position of furball on the grid
      @valid_moves << Move.new(furball_position, :up) if !next_furball_in_direction(x, y, :up).nil?
      @valid_moves << Move.new(furball_position, :down) if !next_furball_in_direction(x, y, :down).nil?
      @valid_moves << Move.new(furball_position, :left) if !next_furball_in_direction(x, y, :left).nil?
      @valid_moves << Move.new(furball_position, :right) if !next_furball_in_direction(x, y, :right).nil?
    end
  end
  
  
  def next_furball_in_direction(start_x, start_y, direction)
    case direction
    when :up
      return nil if start_y - 1 >= 0 && @grid[start_y - 1][start_x] == 1
      (start_y - 2).downto(0).each do |y|
        return Point.new(start_x, y) if @grid[y][start_x] == 1
      end
    when :down
      return nil if start_y + 1 < @grid.length && @grid[start_y + 1][start_x] == 1
      (start_y + 2).upto(@grid.length - 1).each do |y|
        return Point.new(start_x, y) if @grid[y][start_x] == 1
      end
    when :left
      return nil if start_x - 1 >= 0 && @grid[start_y][start_x - 1] == 1
      (start_x - 2).downto(0).each do |x|
        return Point.new(x, start_y) if @grid[start_y][x] == 1
      end
    when :right
      return nil if start_x + 1 < @grid[0].length && @grid[start_y][start_x + 1] == 1
      (start_x + 2).upto(@grid[start_y].length).each do |x|
        return Point.new(x, start_y) if @grid[start_y][x] == 1
      end
    end
    
    return nil
  end
  
  
  def apply_move(move)                                                            
    raise ArgumentError, 'Move cannot be nil' if move.nil?                                              
    
    @move = move # Store move for use later when printing a solution
    
    x = move.point.x
    y = move.point.y
    direction = move.direction
    
    next_furball_location = next_furball_in_direction(x, y, direction)
        
    raise "First furball in direction #{direction} does not exist for move #{move}" if next_furball_location.nil?
    
    next_space_x = next_furball_location.x
    next_space_y = next_furball_location.y
    
    until next_furball_location.nil?
      case direction
      when :up
        next_space_y += 1
      when :down
        next_space_y -= 1
      when :left
        next_space_x += 1
      when :right
        next_space_x -= 1
      else
        raise "Invalid direction #{direction} specified"
      end
      
      @grid[y][x] = 0
      @grid[next_space_y][next_space_x] = 1
      
      x = next_furball_location.x
      y = next_furball_location.y
      
      next_furball_location = next_furball_in_direction(x, y, direction)
    end
    
    # 'Move' the final furball off the grid
    @grid[y][x] = 0
    
    # Recompute valid move list
    find_furballs
    compute_valid_moves
  end
     
  
  def child_board_from_move(move)
    # Create an entirely new grid 
    grid = []
    @grid.each do |row|
      grid_row = []
      row.each do |col|
        grid_row << col
      end
      grid << grid_row
    end
         
    board = Board.new(grid, self)
    board.apply_move(move)    
    board
  end
  
  
  def generate_children
    @valid_moves.each do |move|
      child_board = child_board_from_move(move)
      @child_boards << child_board
    end
    
    @child_boards.each do |child_board|
      child_board.generate_children
    end
  end
  
  
  def check_for_solution(solved_boards)
    solved_boards << self if @furballs.length == 1
    @child_boards.each do |child_board|
      child_board.check_for_solution(solved_boards)
    end
  end
  
  
  def draw
    (@grid[0].length * 2 + 1).times { print '_' }
    puts
    
    @grid.each_index do |row|
      @grid[row].each_index do |col|
        print '|' + (@grid[row][col].to_s == '1' ? '#' : '_')
      end
      puts '|'
    end         
        
    # (@grid[0].length * 2 + 1).times { print '˘' }
    puts
  end
  
end