#!/usr/bin/env ruby

require 'gosu'

class Ball
  def initialize(window)
    @image = Gosu::Image.new(window, "media/red_ball.png", false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end

  def goto(x, y)
    @x, @y = x, y
  end

  def turn_left
    @angle -= 4.5
  end

  def turn_right
    @angle += 4.5
  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 720
    @y %= 480

    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
end

class BallBoxer < Gosu::Window
  def initialize
    super 720, 480, false # (width, height, fullscreen)
    self.caption = "Ball Boxer on Gosu"

    @background_image = Gosu::Image.new(
      self, "media/ballboxer_dark_background.jpg", true)

    @ball = Ball.new(self)
    @ball.goto(360, 240)
  end

  def update
    if button_down?(Gosu::KbLeft) || button_down?(Gosu::GpLeft)
      @ball.turn_left
    end
    if button_down?(Gosu::KbRight) || button_down?(Gosu::GpRight)
      @ball.turn_right
    end
    if button_down?(Gosu::KbUp) || button_down?(Gosu::GpButton0)
      @ball.accelerate
    end
    @ball.move
  end

  def draw
    @ball.draw
    @background_image.draw(0, 0, 0)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = BallBoxer.new
window.show
