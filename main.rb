require 'rubygems'
require 'sinatra'

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
    r_b.move(20.0, 225)
    r_c.move(20.0, -45)
    i = 0
    turn_length = 5
    while (r_a.distance_to(you) > 0.1)&&(r_b.distance_to(you) > 0.1)&&(r_c.distance_to(you) > 0.1)
      r_a.move_toward(you, turn_length)
      r_b.move_toward(you, turn_length)
      r_c.move_toward(you, turn_length)
      you.move_toward(direction, turn_length)
      i+=1
      break if ((turn_length*i) > 250_000)
    end
    return (turn_length*i)/1000.0
  end
  def graph(your_speed, a_speed, b_speed, c_speed)
    linear_output = (0..120).to_a.map{|i| (i*3).to_f}.map{|i| [i, test_run(i, your_speed, a_speed, b_speed, c_speed)]}
    maximum = (linear_output.map{|i| i[1]}.max)*1.1
    multiplier = 100.0/maximum
    return "http://chart.apis.google.com/chart?cht=s&chd=t:"+linear_output.map{|i| sprintf("%.3f",i[0]/3.6) }.join(",")+"|"+linear_output.map{|i| sprintf("%.3f",i[1]*multiplier)}.join(",") + "|40&chxt=x,y&chs=500x400&chxr=0,0,360,45|1,0,#{maximum}&chtt=Survival%20Time%20(s)%20vs%20Angle%20of%20Run%20(degrees)"
  end
end
