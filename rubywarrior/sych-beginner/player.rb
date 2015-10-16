class Player

  class EndTurn < StandardError; end

  attr_reader :warrior, :prev_health, :current_direction

  def play_turn(warrior)
    @warrior = warrior

    @current_direction = :backward
    @prev_health ||= warrior.health

    begin
      change_direction_if_needed!
      rescue_captive!
      kill_em_all!
    rescue EndTurn
    end

    @prev_health = warrior.health
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
      if current_direction == :backward
        @current_direction == :forward
      else
        @current_direction == :backward
      end
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
    return if (warrior.health > 15 || under_attack?)
    rest!
  end

  def rescue_captive!
    if warrior.feel.captive?
      rescue!
    end
  end

end
