require 'rubygems'
require 'sinatra'
require 'haml'

get "/" do
  haml :index
end


helpers do
  class Point
    attr_accessor :x, :y, :speed
    def initialize(x, y, speed)
      @x = x
      @y = y
      @speed = speed
    end
    def distance_to(point)
      ((@x-point.x)**2 + (@y-point.y)**2)**0.5
    end
    def angle_to(point)
       (180/Math::PI) * Math.atan2((point.y-@y),(point.x-@x))
    end
    def move(distance, direction)
      @x += Math.cos(direction*Math::PI/180.0)*distance
      @y += Math.sin(direction*Math::PI/180.0)*distance
    end
    def move_toward(point, time) #run at point for time milliseconds
      #puts "moving " + (@speed*(time/1000.0)).to_s + " meters at an angle of " + angle_to(point).to_s + "degrees"
      if point.class == Point
        move((@speed*(time/1000.0)),angle_to(point))
      elsif point.class == Float || point.class == Fixnum
        move((@speed*(time/1000.0)), point)
      else
        puts "Invalid input."
      end
    end
    def to_s
      "(#{@x},#{@y})"
    end
  end

  def test_run(direction, y, a, b, c)
    you = Point.new(0.0, 0.0, y)
    r_a = Point.new(0.0, 20.0, a)
    r_b = Point.new(0.0, 0.0, b)
    r_c = Point.new(0.0, 0.0, c)
    r_b.move(20.0, 210)
    r_c.move(20.0, -30)
    i = 0
    turn_length = 5
    while (r_a.distance_to(you) > 0.1)&&(r_b.distance_to(you) > 0.1)&&(r_c.distance_to(you) > 0.1)
      r_a.move_toward(you, turn_length)
      r_b.move_toward(you, turn_length)
      r_c.move_toward(you, turn_length)
      you.move_toward(direction, turn_length)
      i+=1
      break if ((turn_length*i) > 20_000)
    end
    return (turn_length*i)/1000.0
  end
  
  def test_run_trace(direction, y, a, b, c)
    out = []
    you = Point.new(0.0, 0.0, y)
    r_a = Point.new(0.0, 20.0, a)
    r_b = Point.new(0.0, 0.0, b)
    r_c = Point.new(0.0, 0.0, c)
    r_b.move(20.0, 210)
    r_c.move(20.0, -30)
    i = 0
    turn_length = 5
    while (r_a.distance_to(you) > 0.1)&&(r_b.distance_to(you) > 0.1)&&(r_c.distance_to(you) > 0.1)
      r_a.move_toward(you, turn_length)
      r_b.move_toward(you, turn_length)
      r_c.move_toward(you, turn_length)
      you.move_toward(direction, turn_length)
      if (i%10 == 0)
        out << [you.x, you.y]
        out << [r_a.x, r_a.y]
        out << [r_b.x, r_b.y]
        out << [r_c.x, r_c.y]
      end
      i+=1
      break if ((turn_length*i) > 20_000)
    end
    return out
  end
  
  def graphs(your_speed, a_speed, b_speed, c_speed)
    linear_output = (0..119).to_a.map{|i| (i*3).to_f}.map{|i| [i, test_run(i, your_speed, a_speed, b_speed, c_speed)]}
    best_shot = linear_output.map{|i| [i[1], i[0]]}.max
    maximum = best_shot[0]*1.1
    max_angle = best_shot[1]
    multiplier = 100.0/maximum
    30.times {linear_output.push(linear_output.shift)}
    linear_output.reverse!
    best_trace = test_run_trace(max_angle, your_speed, a_speed, b_speed, c_speed)
    max_x = best_trace.map{|i| i[0]}.max
    min_x = best_trace.map{|i| i[0]}.min
    
    max_y = best_trace.map{|i| i[1]}.max
    min_y = best_trace.map{|i| i[1]}.min
    
    linear = "http://chart.apis.google.com/chart?cht=s&chd=t:"+linear_output.map{|i| sprintf("%.3f",i[0]/3.6) }.join(",")+"|"+linear_output.map{|i| sprintf("%.3f",i[1]*multiplier)}.join(",") + "|40&chxt=x,y&chs=500x400&chg=33.33,200,2,2,25&chxr=0,0,360,45|1,0,#{maximum}&chtt=Survival%20Time%20(s)%20vs%20Angle%20of%20Run%20(degrees)"
    radial = "http://chart.apis.google.com/chart?cht=rs&chs=400x400&chd=t:#{linear_output.map{|i| sprintf("%.3f",i[1]*multiplier)}.join(",")}&chxt=x&chxl=0:#{linear_output.map{|i| ((i[0]%10 == 0) ? i[0].to_i : "" )}.join("|")}"
    trace = "http://chart.apis.google.com/chart?cht=s&chd=t:"+best_trace.map{|i| sprintf("%.1f",i[0]*2.5+50) }.join(",")+"|"+best_trace.map{|i| sprintf("%.1f", i[1]*2.5+50)}.join(",") + "|40&chco=6666FF|FF6600|FF0044|FFDD22&chxt=x,y&chs=500x400&chg=33.33,200,2,2,25&chxr=0,#{min_x},#{max_x},45|1,#{min_y},#{max_y},10&chtt=Survival Trace of Running in Optimal Direction (#{max_angle})"
    return {:linear => linear, :radial => radial, :trace => trace}
  end
end
