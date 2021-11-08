require_relative 'interactor'
require_relative 'game'
require "test/unit"
require "test/unit/assertions"

class TestActionFactory < Test::Unit::TestCase
   def test_mark_mine_factory
        action = ActionFactory::Factory.new.create_action('mine 3, 4')
        assert_equal(action.class, MarkMineAction)
        assert_equal(action.x, 3)
        assert_equal(action.y, 4)
   end 

   def test_reveal_tile_factory
        action = ActionFactory::Factory.new.create_action('rev 2, 4')
        assert_equal(action.class, RevealTileAction)
        assert_equal(action.x, 2)
        assert_equal(action.y, 4)
   end
end