class Player

  attr_reader :warrior

  def rest_if_needed
    return if warrior.health > 5
    warrior.rest!
    true
  end

  def play_turn(warrior)
    @warrior = warrior

    return if rest_if_needed

    if warrior.feel.empty?
      warrior.walk!
    else
      warrior.attack!
    end
  end

end
