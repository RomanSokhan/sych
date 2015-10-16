require 'environment'
require 'health_observer'

class Controller

  SHOOT_DISTANCE = 3

  class EndTurn < StandardError; end

  def initialize
    @environment = Environment.new
    @environment.on_all_rescued_at_dead_end { change_direction }
    @hp_observer = HealthObserver.new
  end

  def update(warrior)
    @warrior = warrior
    @current_direction ||= :backward
  end

  def do_action
    hp_observer.update(warrior.health)
    begin
      tactical_retreat
      look
      change_direction_if_needed!
      look
      rescue_captive!
      go!
    rescue EndTurn
    end
    hp_observer.update(warrior.health)
  end

  private

  attr_reader :warrior, :current_direction, :hp_observer, :environment

  def look
    if enemy_disatance = danger(current_direction)
      shoot! if enemy_disatance <= SHOOT_DISTANCE
    end
  end

  def shoot!
    warrior.shoot!(current_direction) and raise EndTurn
  end

  def doing_retreat?
    @dangerous_direction
  end

  def danger(direction)
    spaces = warrior.look(direction)
    environment.danger(spaces, current_direction)
  end

  def stop_retreat
    change_direction
    @dangerous_direction = nil
  end

  def tactical_retreat
    if doing_retreat?
      if no_escape?(current_direction)
        stop_retreat
      else
        walk! if hp_observer.under_attack?
        rest_if_needed!
        stop_retreat
      end
    end

    return if no_escape?(opposite_direction)

    if hp_observer.very_low_health? && !danger(opposite_direction)
      do_retreat
    end
  end

  def no_escape?(direction)
    spaces = warrior.look(direction)
    Environment.no_escape?(spaces)
  end

  def do_retreat
    @dangerous_direction = current_direction
    change_direction
  end

  def change_direction
    @current_direction = opposite_direction
  end

  def opposite_direction
    current_direction == :backward ? :forward : :backward
  end

  def walk!
    warrior.walk!(current_direction) and raise EndTurn
  end

  def attack!
    warrior.attack!(current_direction) and raise EndTurn
  end

  def rescue!
    warrior.rescue!(current_direction) and raise EndTurn
  end

  def rest!
    warrior.rest! and raise EndTurn
  end

  def change_direction_if_needed!
    if feel.wall?
      change_direction
    elsif feel.stairs?
      if !environment.all_captives_rescued?
        change_direction
      end
    end
  end

  def feel
    warrior.feel(current_direction)
  end

  def go!
    if feel.empty?
      rest_if_needed!
      walk!
    end
  end

  def rest_if_needed!
    return if hp_observer.need_rest?
    rest!
  end

  def rescue_captive!
    if feel.captive?
      rescue!
    end
  end

end
