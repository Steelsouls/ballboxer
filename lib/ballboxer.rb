#!/usr/bin/env ruby

# GameWindow.update() is called 60 times/second

require 'gosu'

module ZOrder
  Background, Player, Ball, Effects, UI = 0, 1, 2, 3, 4
end


module BallBoxer
  VERSION = '0.3'

  # class Animations
  #   def initialize(window)
  #     @smoke_ring = Gosu::Image::load_tiles(window, "media/smoke_ring_anim.png", 30, 30, false)
  #   end
  # end

  class Player
    attr_accessor :x, :y
    attr_reader :lives
    def initialize(window)
      @image = Gosu::Image.new(window, "media/dwarf_miner_idle.png", false)
      @swing_image = Gosu::Image.new(window, "media/dwarf_miner_swing.png", false)
      @defeat_animation = Gosu::Image::load_tiles(window, "media/smoke_ring_anim_long.png", 30, 30, false)
      @x = @y = @vel_x = @vel_y = @swing_timer = @defeat_timer = @immunity_timer = @score = 0.0
      @direction = 1
      @lives = 3
      @swinging = false
      @defeated = false
      @immune = false
    end

    def width
      @image.width
    end

    def height
      @image.height
    end

    def interact
      if @swinging && @swing_timer > 0

      else
        get_hit unless @immune
      end
    end

    def swing
      if @swinging
        @swing_timer -= 1
      else
        @swing_timer = 30
        @swinging = true
      end
    end

    def reset_swing
      @swinging = false
    end

    def get_hit
      unless @defeated
        @lives -= 1
        @defeated = true
        @defeat_timer = 30
      end
    end

    def respawn
      @defeat_timer -= 1
      if @defeat_timer <= 0
        @x, @y = rand(720), rand(480)
        @defeated = false
        @immune = true
        @immunity_timer = 120
      end
    end

    def check_immunity
      @immunity_timer -= 1
      @immune = false if @immunity_timer <= 0
      if @immune
        @color = Gosu::Color.rgba(255, 140, 17, 255)
      else
        @color = Gosu::Color.rgba(255, 255, 255, 255)
      end
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
      @vel_y -= 0.9
    end

    def move_down
      @vel_y += 0.9
    end

    def move
      @x += @vel_x unless @defeated
      @y += @vel_y unless @defeated
      @x %= 720
      @y %= 480

      @vel_x *= 0.75
      @vel_y *= 0.75

      respawn if @defeated
      check_immunity
    end

    def draw
      if @swinging && @swing_timer > 0
        @swing_image.draw(@x - @image.width/2, @y - @image.height/2, ZOrder::Player, @direction, 1, @color)
      elsif @defeated
        img = @defeat_animation[Gosu::milliseconds / 125 % @defeat_animation.size]
        img.draw(@x - img.width/2, @y - img.height/2, ZOrder::Effects, @direction, 1, @color)
      else
        @image.draw(@x - @swing_image.width/2, @y - @swing_image.height/2,
          ZOrder::Player, @direction, 1, @color)
      end
    end
  end

  class Ball
    attr_accessor :x, :y
    def initialize(window)
      @image = Gosu::Image.new(window, "media/red_ball.png", false)
      @x = @y = @vel_x = @vel_y = 0.0
      @angle = rand(360)
    end

    def width
      @image.width
    end

    def height
      @image.height
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
      @image.draw_rot(@x, @y, ZOrder::Ball, @angle)
    end
  end

  class GameWindow < Gosu::Window
    def initialize
      super 720, 480, false # (width, height, fullscreen)
      self.caption = "Ball Boxer on Gosu"

      @background_image = Gosu::Image.new(
        self, "media/ballboxer_background.jpg", true)

      @ball = Ball.new(self)
      @ball.goto(180, 120)

      @player = Player.new(self)
      @player.goto(360, 240)

      # @animations = Animations.new(self)
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
      if button_down?(Gosu::KbSpace) || button_down?(Gosu::GpButton0)
        @player.swing
      end

      @player.move
      @ball.move
      if Gosu::distance(@player.x, @player.y, @ball.x + @ball.width/2, @ball.y) < 30
        @player.interact
      end
      close if @player.lives < 0
    end

    def draw
      @player.draw
      @ball.draw
      @background_image.draw(0, 0, ZOrder::Background)
    end

    def button_up(id)
      if id == Gosu::KbSpace
        @player.reset_swing
      end
    end

    def button_down(id)
      if id == Gosu::KbEscape
        close
      end
    end
  end
end

window = BallBoxer::GameWindow.new
window.show
