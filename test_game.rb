require_relative 'game'
require "test/unit"
require "test/unit/assertions"

class TestTiles < Test::Unit::TestCase
  def test_get_neighbours_of
    tiles = Tiles.new(5)
    25.times { |i| tiles << Tile.new(i) }

    assert_equal(tiles.get_neighbours_of(0), [Tile.new(1), Tile.new(5), Tile.new(6)])
    assert_equal(tiles.get_neighbours_of(7), [Tile.new(1), Tile.new(2), Tile.new(3), Tile.new(6), Tile.new(8), Tile.new(11), Tile.new(12), Tile.new(13)])
    assert_equal(tiles.get_neighbours_of(9), [Tile.new(3), Tile.new(4), Tile.new(8), Tile.new(13), Tile.new(14)])
    assert_equal(tiles.get_neighbours_of(24), [Tile.new(18), Tile.new(19), Tile.new(23)])
  end
end