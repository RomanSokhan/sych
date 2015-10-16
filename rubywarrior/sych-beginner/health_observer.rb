class HealthObserver

  VERY_LOW_HP = 10
  ENOUGH_HEALTH = 10

  def very_low_health?
    current_hp < VERY_LOW_HP
  end

  def update(current_hp)
    @prev_health = @current_hp || current_hp
    @current_hp = current_hp
  end

  def need_rest?
    (current_hp > ENOUGH_HEALTH) || under_attack?
  end

  def under_attack?
    @prev_health > current_hp
  end

  attr_reader :current_hp

end
