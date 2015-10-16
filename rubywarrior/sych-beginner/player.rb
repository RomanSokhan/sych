require 'controller'

class Player

  def initialize
    super
    @controller = Controller.new
  end

  def play_turn(warrior)
    @controller.update(warrior)
    @controller.do_action
  end

end
