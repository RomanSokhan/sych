class Player

  class EndTurn < StandardError; end

  SHOOT_DISTANCE = 3
  VERY_LOW_HP = 10
  ENOUGH_HEALTH = 10

  def play_turn(warrior)
    @warrior = warrior

    @current_direction ||= :backward
    @prev_health ||= warrior.health

    begin
      tactical_retreat
      look
      change_direction_if_needed!
      look
      rescue_captive!
      go!
    rescue EndTurn
    end

    @prev_health = warrior.health
  end

  private

  attr_reader :warrior, :prev_health, :current_direction

  def look
    if enemy_disatance = danger(current_direction)
      shoot! if enemy_disatance <= SHOOT_DISTANCE
    end
  end

  def discover(env)
    left_wall_discovered?(env) unless @left_wall_discovered
    right_wall_discovered?(env) unless @right_wall_discovered
    everything_discovered? unless @everything_discovered
    all_captives_rescued?(env) unless @all_captives_rescued
  end

  def left_wall_discovered?(env)
    if current_direction == :backward
      @left_wall_discovered = wall_present?(env)
    end
  end

  def right_wall_discovered?(env)
    if current_direction == :forward
      @right_wall_discovered = wall_present?(env)
    end
  end

  def wall_present?(env)
    env.find { |space| space.wall? }
  end

  def captive_present?(env)
    env.find { |space| space.captive? }
  end

  def everything_discovered?
    @everything_discovered = @left_wall_discovered && @right_wall_discovered
  end

  def no_captives_left?(env)
    !captive_present?(env)
  end

  def all_captives_rescued?(env)
    @all_captives_rescued = @everything_discovered && no_captives_left?(env)
    if @all_captives_rescued
      if !env.find{ |space| space.stairs? }
        change_direction
      end
    end
  end

  def shoot!
    warrior.shoot!(current_direction) and raise EndTurn
  end

  def very_low_health?
    warrior.health < VERY_LOW_HP
  end

  def doing_retreat?
    @dangerous_direction
  end

  def danger(direction)
    env = warrior.look(direction)

    discover(env)

    env.each_with_index do |space, index|
      return false if space.captive?
      return index + 1 if space.enemy?
    end
    false
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
        walk! if under_attack?
        rest_if_needed!
        stop_retreat
      end
    end

    return if no_escape?(opposite_direction)

    if very_low_health? && !danger(opposite_direction)
      do_retreat
    end
  end

  def no_escape?(direction)
    env = warrior.look(direction)
    next_space = env.first
    next_space.wall? || next_space.enemy?
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
      if !@all_captives_rescued
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

  def under_attack?
    prev_health > warrior.health
  end

  def rest_if_needed!
    return if (warrior.health > ENOUGH_HEALTH || under_attack?)
    rest!
  end

  def rescue_captive!
    if feel.captive?
      rescue!
    end
  end

end
