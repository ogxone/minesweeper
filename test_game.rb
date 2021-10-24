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

class TestBoard < Test::Unit::TestCase
  def test_get_tile
    board_gen = BoardGenerator::Generator.new(
      BoardGenerator::Params.new.with_dims(4, 5).with_mines(2),
      BoardGenerator::PredefinedMinesAssigner.new([0, 3, 16])
    )

    board = board_gen.generate

    assert_equal(0, board.get_tile_at(0, 0).num)
    assert_equal(1, board.get_tile_at(1, 0).num)
    assert_equal(2, board.get_tile_at(2, 0).num)
    assert_equal(3, board.get_tile_at(3, 0).num)

    assert_equal(4, board.get_tile_at(0, 1).num)
    assert_equal(5, board.get_tile_at(1, 1).num)
    assert_equal(6, board.get_tile_at(2, 1).num)
    assert_equal(7, board.get_tile_at(3, 1).num)

    assert_equal(8, board.get_tile_at(0, 2).num)
    assert_equal(9, board.get_tile_at(1, 2).num)
    assert_equal(10, board.get_tile_at(2, 2).num)
    assert_equal(11, board.get_tile_at(3, 2).num)

    assert_equal(12, board.get_tile_at(0, 3).num)
    assert_equal(13, board.get_tile_at(1, 3).num)
    assert_equal(14, board.get_tile_at(2, 3).num)
    assert_equal(15, board.get_tile_at(3, 3).num)

    assert_equal(16, board.get_tile_at(0, 4).num)
    assert_equal(17, board.get_tile_at(1, 4).num)
    assert_equal(18, board.get_tile_at(2, 4).num)
    assert_equal(19, board.get_tile_at(3, 4).num)

  end

  def test_mark_generation
    board_gen = BoardGenerator::Generator.new(
      BoardGenerator::Params.new.with_dims(4, 5).with_mines(3),
      BoardGenerator::PredefinedMinesAssigner.new([0, 3, 16])
    )

    board = board_gen.generate

    assert_tile(board.get_tile_at(0, 0), create_tile(0, false, true, -1))
    assert_tile(board.get_tile_at(1, 0), create_tile(1, false, false, 1))
    assert_tile(board.get_tile_at(2, 0), create_tile(2, false, false, 1))
    assert_tile(board.get_tile_at(3, 0), create_tile(3, false, true, -1))
    
    assert_tile(board.get_tile_at(0, 1), create_tile(4, false, false, 1))
    assert_tile(board.get_tile_at(1, 1), create_tile(5, false, false, 1))
    assert_tile(board.get_tile_at(2, 1), create_tile(6, false, false, 1))
    assert_tile(board.get_tile_at(3, 1), create_tile(7, false, false, 1))

    assert_tile(board.get_tile_at(0, 2), create_tile(8, false, false, 0))
    assert_tile(board.get_tile_at(1, 2), create_tile(9, false, false, 0))
    assert_tile(board.get_tile_at(2, 2), create_tile(10, false, false, 0))
    assert_tile(board.get_tile_at(3, 2), create_tile(11, false, false, 0))
    
    assert_tile(board.get_tile_at(0, 3), create_tile(12, false, false, 1))
    assert_tile(board.get_tile_at(1, 3), create_tile(13, false, false, 1))
    assert_tile(board.get_tile_at(2, 3), create_tile(14, false, false, 0))
    assert_tile(board.get_tile_at(3, 3), create_tile(15, false, false, 0))

    assert_tile(board.get_tile_at(0, 4), create_tile(16, false, true, -1))
    assert_tile(board.get_tile_at(1, 4), create_tile(17, false, false, 1))
    assert_tile(board.get_tile_at(2, 4), create_tile(18, false, false, 0))
    assert_tile(board.get_tile_at(3, 4), create_tile(19, false, false, 0))
  end

  def test_reveal
    # * - - *
    # 1 1 1 1
    # - c - -
    # 1 1 - -
    # * 1 - -
    board_gen = BoardGenerator::Generator.new(
      BoardGenerator::Params.new.with_dims(4, 5).with_mines(3),
      BoardGenerator::PredefinedMinesAssigner.new([0, 3, 16])
    )

    board = board_gen.generate
    
    board.reveal_tile_at 2, 3

    assert_tile(board.get_tile_at(0, 0), create_tile(0, false, true, -1))
    assert_tile(board.get_tile_at(1, 0), create_tile(1, false, false, 1))
    assert_tile(board.get_tile_at(2, 0), create_tile(2, false, false, 1))
    assert_tile(board.get_tile_at(3, 0), create_tile(3, false, true, -1))
    
    assert_tile(board.get_tile_at(0, 1), create_tile(4, true, false, 1))
    assert_tile(board.get_tile_at(1, 1), create_tile(5, true, false, 1))
    assert_tile(board.get_tile_at(2, 1), create_tile(6, true, false, 1))
    assert_tile(board.get_tile_at(3, 1), create_tile(7, true, false, 1))

    assert_tile(board.get_tile_at(0, 2), create_tile(8, true, false, 0))
    assert_tile(board.get_tile_at(1, 2), create_tile(9, true, false, 0))
    assert_tile(board.get_tile_at(2, 2), create_tile(10, true, false, 0))
    assert_tile(board.get_tile_at(3, 2), create_tile(11, true, false, 0))
    
    assert_tile(board.get_tile_at(0, 3), create_tile(12, true, false, 1))
    assert_tile(board.get_tile_at(1, 3), create_tile(13, true, false, 1))
    assert_tile(board.get_tile_at(2, 3), create_tile(14, true, false, 0))
    assert_tile(board.get_tile_at(3, 3), create_tile(15, true, false, 0))

    assert_tile(board.get_tile_at(0, 4), create_tile(16, false, true, -1))
    assert_tile(board.get_tile_at(1, 4), create_tile(17, true, false, 1))
    assert_tile(board.get_tile_at(2, 4), create_tile(18, true, false, 0))
    assert_tile(board.get_tile_at(3, 4), create_tile(19, true, false, 0))

  end

  def create_tile num, is_revealed, is_mine, mines_around = 0
    tile = Tile.new(num)
    if is_revealed
      tile.reveal
    end

    if is_mine
      tile.mark_as_mine
    end

    tile.mines_around = mines_around

    tile
  end

  def assert_tile actual, expected
    assert_equal actual.is_mine, expected.is_mine
    assert_equal actual.is_revealed, expected.is_revealed
    assert_equal actual.mines_around, expected.mines_around
  end
end 