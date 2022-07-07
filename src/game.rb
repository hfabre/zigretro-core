class Game
  SPEED = 1

  def initialize
    @colors = [RED, GREEN, BLUE, GREY, WHITE]
    @color = WHITE
    @pos_x = 0
    @pos_y = 0
  end

  def move(direction)
    case direction
    when :up
      @pos_y -= SPEED
    when :down
      @pos_y += SPEED
    when :right
      @pos_x += SPEED
    when :left
      @pos_x -= SPEED
    end
  end

  def change_color
    @color = @colors.sample
  end

  def tick
    draw_rect(@pos_x, @pos_y, 10, 10, @color)
  end
end

def run
  @game ||= Game.new
  @game.tick
end

def up_press
  @game.move(:up)
end

def down_press
  @game.move(:down)
end

def right_press
  @game.move(:right)
end

def left_press
  @game.move(:left)
end

def start_press
  @game.change_color
end
