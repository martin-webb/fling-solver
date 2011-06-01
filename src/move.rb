class Move
  attr_reader :point, :direction
  
  def initialize(point, direction)
    @point = point
    @direction = direction
  end
  
  def to_s
     "[#@point - #@direction]"
  end
end