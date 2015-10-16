class Player

  class EndTurn < StandardError; end

  SHOOT_DISTANCE = 3

  attr_reader :warrior, :prev_health, :current_direction, :dangerous_direction

  def play_turn(warrior)
    @warrior = warrior

    @current_direction ||= :backward
    @prev_health ||= warrior.health

    begin
      tactical_retreat
      shoot_enemies
      rescue_captive!
      change_direction_if_needed!
      kill_em_all!
    rescue EndTurn
    end

    @prev_health = warrior.health
  end

  def shoot_enemies
    enemy_disatance = danger
    if enemy_disatance
      if enemy_disatance <= SHOOT_DISTANCE
        shoot!
      end
    end
  end

  def shoot!
    warrior.shoot! and raise EndTurn
  end

  def very_low_health?
    warrior.health < 20
  end

  def doing_retreat?
    @dangerous_direction
  end

  def danger
    env = warrior.look(current_direction)
    env.each_with_index do |space, index|
      return false if space.captive?
      return index + 1 if space.enemy?
    end
    false
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
    if feel.wall?
      change_direction
    end
  end

  def feel
    warrior.feel(current_direction)
  end

  def kill_em_all!
    if feel.empty?
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
    if feel.captive?
      rescue!
    end
  end

end
