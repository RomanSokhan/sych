class Player

  class EndTurn < StandardError; end

  attr_reader :warrior, :prev_health

  def play_turn(warrior)
    @prev_health ||= warrior.health
    @warrior = warrior

    begin
      rescue_captive!
      kill_em_all!
    rescue EndTurn
    end

    @prev_health = warrior.health
  end

  def kill_em_all!
    if warrior.feel.empty?
      rest_if_needed!
      warrior.walk!
    else
      warrior.attack!
    end
  end

  def under_attack?
    prev_health > warrior.health
  end

  def rest_if_needed!
    return if (warrior.health > 15 || under_attack?)
    warrior.rest! and raise EndTurn
  end

  def rescue_captive!
    if warrior.feel.captive?
      warrior.rescue! and raise EndTurn
    end
  end

end
