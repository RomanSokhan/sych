class Environment

  def self.no_escape?(spaces)
    next_space = spaces.first
    next_space.wall? || next_space.enemy?
  end

  def on_all_rescued_at_dead_end(&block)
    @on_all_rescued_at_dead_end = block
  end

  def danger(spaces, current_direction)
    @spaces = spaces
    @current_direction = current_direction
    discover

    @spaces.each_with_index do |space, index|
      return false if space.captive?
      return index + 1 if space.enemy?
    end
    false
  end

  def all_captives_rescued?
    @all_captives_rescued
  end

  private

  def discover
    left_wall_discovered? unless @left_wall_discovered
    right_wall_discovered? unless @right_wall_discovered
    everything_discovered? unless @everything_discovered
    check_all_captives_rescued unless @all_captives_rescued
  end

  def left_wall_discovered?
    if @current_direction == :backward
      @left_wall_discovered = wall_present?
    end
  end

  def right_wall_discovered?
    if @current_direction == :forward
      @right_wall_discovered = wall_present?
    end
  end

  def wall_present?
    @spaces.find { |space| space.wall? }
  end

  def captive_present?
    @spaces.find { |space| space.captive? }
  end

  def everything_discovered?
    @everything_discovered = @left_wall_discovered && @right_wall_discovered
  end

  def no_captives_left?
    !captive_present?
  end

  def check_all_captives_rescued
    @all_captives_rescued = @everything_discovered && no_captives_left?
    if @all_captives_rescued
      if !@spaces.find{ |space| space.stairs? }
        @on_all_rescued_at_dead_end.call
      end
    end
  end

end
