# from Towelie
class Array
  def stepwise
    self.each do |element1|
      self.each do |element2|
        next if element1 == element2
        yield element1, element2
      end
    end
  end
end

require 'erb'

Velocity = Struct.new(:x, :y)

Circle = Struct.new(:x, :y, :radius, :depth, :distance_threshold, :velocity) do
  attr_accessor :connections

  def move
    self.x += self.velocity.x
    self.y += self.velocity.y
    bounce_at_boundaries
    self.connections = []
  end

  def reverse
    self.velocity.x = -1 * self.velocity.x
    self.velocity.y = -1 * self.velocity.y
  end

  def bounce_at_boundaries
    if self.x < 0
      self.x = 0
      reverse
    end

    if self.y < 0
      self.y = 0
      reverse
    end

    if self.x > 1080
      self.x = 1080
      reverse
    end

    if self.y > 1920
      self.y = 1920
      reverse
    end

    def stroke_width
      case depth
      when :near
        10
      when :mid
        4
      when :far
        3
      end
    end

    def color
      case depth
      when :near
        "hsl(0, 0, 255)"
      when :mid
        "hsl(0, 0, 115)"
      when :far
        "hsl(0, 0, 40)"
      end
    end
  end

  def communicate(other)
    self.connections ? self.connections << other : self.connections = [other]
  end
end

def frame_id(number)
  "output/tween#{sprintf("%.4d", number)}"
end

def render(template)
  ERB.new(File.read(template)).result(binding)
end

# this is really another render method
def graphic(number)
  File.open("#{frame_id(number)}.svg", "w") do |file|
    file.write render("bit101_style.erb")
  end

  system("convert #{frame_id(number)}.svg #{frame_id(number)}.jpg")
  # system("java -jar ~/Downloads/batik-1.7/batik-rasterizer.jar #{frame_id(number)}.svg")
  File.unlink("#{frame_id(number)}.svg")

  print "+"
end

def start
  # FIXME: Circle#depth should actually be a number from 0 to something
  options = [:far, :mid, :near]

  random_circle = lambda do
    Circle.new(rand(1080),
               rand(1920),
               rand(10) + 10,
               options.sample,
               175,
               Velocity.new(rand(50) - 25,
                            rand(50) - 25))
  end

  @circles = []
  65.times {@circles << random_circle[]}
end



# here we go

start
(0..90).each do |number|
  @circles.each {|circle| circle.move}

  by_depth = @circles.group_by {|c| c.depth}

  [:far, :mid, :near].each do |depth|
    circles = by_depth[depth]

    circles.stepwise do |circle1, circle2|
      delta_x = circle1.x - circle2.x
      delta_y = circle1.y - circle2.y
      distance = Math.sqrt((delta_x ** 2) + (delta_y ** 2))

      # this if could also draw on persistent phenomena, e.g., heat, so that proximity to other nodes
      # created effects that only wore off gradually
      if distance < circle1.distance_threshold
        circle1.communicate(circle2)
      end

      print "."
    end
  end

  graphic(number)
end

puts
