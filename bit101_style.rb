require 'erb'

@template = "bit101_style.erb"

Circle = Struct.new(:x, :y, :radius) do
  def move(number)
    self.x = number * rand(10)
    self.y = number * rand(10)
  end
end

random_circle = lambda do
  Circle.new(rand(1280), rand(720), rand(100))
end

@circles = [random_circle[],
            random_circle[],
            random_circle[],
            random_circle[],
            random_circle[]]

def frame_id(number)
  "output/tween#{sprintf("%.4d", number)}"
end

def render(template)
  ERB.new(File.read(template)).result(binding)
end

# this is really another render method
def graphic(number)
  File.open("#{frame_id(number)}.svg", "w") do |file|
    file.write render(@template)
  end
  print "+"
  system("convert #{frame_id(number)}.svg #{frame_id(number)}.jpg")
  print "|"
  File.unlink("#{frame_id(number)}.svg")
  print "/"
end

(0..100).each do |number|
  @circles.each do |circle|
    circle.move(number)
    print "."
  end
  graphic(number)
  puts
end
