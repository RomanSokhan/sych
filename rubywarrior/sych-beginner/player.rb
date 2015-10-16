class Player

  class EndTurn < StandardError; end

  attr_reader :warrior, :prev_health, :current_direction, :dangerous_direction

  def play_turn(warrior)
    @warrior = warrior

    @current_direction ||= :backward
    @prev_health ||= warrior.health

    begin
      # p prev_health, current_direction, dangerous_direction

      tactical_retreat
      rescue_captive!
      change_direction_if_needed!
      kill_em_all!
    rescue EndTurn
    end

    @prev_health = warrior.health
  end

  def very_low_health?
    warrior.health < 12
  end

  def doing_retreat?
    @dangerous_direction
  end

  def tactical_retreat
    if doing_retreat?
      walk! if under_attack?

      rest_if_needed!

      change_direction
      @dangerous_direction = nil
    end

    if very_low_health?
      do_retreat
      walk!
    end
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
    if warrior.feel(current_direction).wall?
      change_direction
    end
  end

  def kill_em_all!
    if warrior.feel.empty?
      rest_if_needed!
      walk!
    else
      attack!
    end
  end

  def under_attack?
    prev_health > warrior.health
  end

  def rest_if_needed!
    return if (warrior.health > 18 || under_attack?)
    rest!
  end

  def rescue_captive!
    if warrior.feel(current_direction).captive?
      rescue!
    end
  end

end
