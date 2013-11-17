#!/usr/bin/env ruby

require 'gosu'

VERSION = '0.2'

class Player
  def initialize(window)
    @image = Gosu::Image.new(window, "media/dwarf_miner_idle.png", false)
    @swing_image = Gosu::Image.new(window, "media/dwarf_miner_swing.png", false)
    @x = @y = @vel_x = @vel_y = 0.0
    @direction = 1
    @idle = true
    @score = 0
    @lives = 3
  end

  def goto(x, y)
    @x, @y = x, y
  end

  def move_left
    @vel_x -= 0.8
    if @direction == 1
      @direction = -1
      @x += @image.width/2
    end
  end

  def move_right
    @vel_x += 0.8
    if @direction == -1
      @direction = 1
      @x -= @image.width/2
    end
  end

  def move_up
    @vel_y -= 0.8
  end

  def move_down
    @vel_y += 0.8
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 720
    @y %= 480

    @vel_x *= 0.75
    @vel_y *= 0.75
  end

  def draw
    if @idle
      @image.draw(@x - @image.width/2, @y - @image.height/2, 1, @direction)
    else
      @swing_image.draw(@x - @swing_image.width/2, @y - @swing_image.height/2, 1, @direction)
    end
  end
end

class Ball
  def initialize(window)
    @image = Gosu::Image.new(window, "media/red_ball.png", false)
    @x = @y = @vel_x = @vel_y = 0.0
    @angle = rand(360)
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

    @vel_x *= 0.985
    @vel_y *= 0.985
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
      self, "media/ballboxer_background.jpg", true)

    @ball = Ball.new(self)
    @ball.goto(180, 120)

    @player = Player.new(self)
    @player.goto(360, 240)
  end

  def needs_cursor?
    true
  end

  def update
    if button_down?(Gosu::KbLeft) || button_down?(Gosu::GpLeft)
      @player.move_left
    end
    if button_down?(Gosu::KbRight) || button_down?(Gosu::GpRight)
      @player.move_right
    end
    if button_down?(Gosu::KbUp) || button_down?(Gosu::GpUp)
      @player.move_up
    end
    if button_down?(Gosu::KbDown) || button_down?(Gosu::GpDown)
      @player.move_down
    end
    @player.move
    @ball.move
  end

  def draw
    @player.draw
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
