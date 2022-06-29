def run
  puts "before new color"
  color = Color.new
  p color # It works i get values inside my instance variables
  p color.object_id
  puts "after new color"
  draw_rect(0, 0, 10, 10, color)
  puts "after drawn"
end
