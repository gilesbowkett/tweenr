require 'erb'

@template = "svg.erb"

Circle = Struct.new(:x, :y)

@circle = Circle.new(0, 0)

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
  system("convert #{frame_id(number)}.svg #{frame_id(number)}.jpg")
  File.unlink("#{frame_id(number)}.svg")
end

(0..100).each do |number|
  @circle.x = number * 9
  @circle.y = number * 7
  graphic(number)
end
