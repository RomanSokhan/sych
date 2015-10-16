class Player

  attr_reader :warrior

  def rest_if_needed!
    return if warrior.health > 15
    warrior.rest!
    true
  end

  def play_turn(warrior)
    @warrior = warrior

    if warrior.feel.empty?
      return if rest_if_needed!
      warrior.walk!
    else
      warrior.attack!
    end
  end

end
