require('byebug')

class Tile
  attr_reader :is_mine, :is_revealed, :marked_as_mine, :num
  attr_accessor :mines_around

  def initialize(num)
    @num = num
    @is_revealed = false
    @is_mine = false
    @mines_around = 0
  end

  def is_mine= is_mine
    @is_mine = is_mine
    if is_mine
      @mines_around = -1
    end
  end

  def mark_as_mine
    self.is_mine= true
  end

  def has_mines_around?
    @mines_around > 0
  end

  def reveal
    @is_revealed = true
  end

  def ==(other)
    self.num == other.num
  end
end

class Tiles < Array
  def initialize(row_length, *several_variants)
    @row_length = row_length
    super(*several_variants)
  end

  def get_neighbours_of(tile_num)
    neighbours = []
    
    tile_row = (tile_num / @row_length.to_f).floor

    indexes = [
      {
        :row => tile_row - 1 ,
        :indexes => [
          tile_num - @row_length - 1,
          tile_num - @row_length,
          tile_num - @row_length + 1,    
        ]
      },
      {
        :row => tile_row,
        :indexes => [
          tile_num - 1,
          tile_num + 1,    
        ]
      },
      {
        :row => tile_row + 1,
        :indexes => [
          tile_num + @row_length - 1,
          tile_num + @row_length,
          tile_num + @row_length + 1
        ]
      }
    ]

    indexes.each do |spec|
      next if spec[:row] < 0

      spec[:indexes].each do |index|
        next if index < 0

        cur_index_row = (index / @row_length.to_f).floor

        next if cur_index_row != spec[:row]

        neighbours << self[index] unless self[index].nil?
      end
    end

    neighbours
  end
end

class Board
  attr_reader :tiles
  def initialize(tiles, dim_x, dim_y)
    @tiles = tiles
    @dim_x = dim_x
    @dim_y = dim_y
  end

  def rows
    row = Array.new
    rows = Array.new
    @tiles.each do |tile|
      row << tile
      if (tile.num + 1) % @dim_x == 0
        if block_given?
          yield(row)
        end

        rows << row
        
        row = Array.new
      end
    end
    rows
  end

  def get_tile_at(x, y)
    x +=1
    y += 1
    i = @dim_x * (y - 1) + x - 1 

    tile = @tiles[i]

    if tile.nil?
      raise TileNotFoundException
    end

    tile
  end

  def reveal_tile tile
    tile.reveal
  
    if tile.is_mine
      raise GameOverException.new('Blow !!')
    end

    if tile.has_mines_around?
      return
    end

    reveal_tile_neighbours tile
    # end
  end

  def reveal_tile_at x, y
    tile = get_tile_at(x, y)
    # p x, y, tile
    reveal_tile tile
  end

  def mark_mine_at x, y
    tile = get_tile_at(x, y)
    tile.is_mine = !tile.is_mine
  end

  private

  def reveal_tile_neighbours(tile)
    neighbour_tiles = @tiles.get_neighbours_of tile.num
    neighbour_tiles.each do |neighbour_tile|
      if neighbour_tile.is_revealed
        next
      end

      neighbour_tile.reveal

      if neighbour_tile.has_mines_around?
        next
      end

      reveal_tile_neighbours neighbour_tile
    end
  end
end

module BoardGenerator
  class RandomMinesAssigner
    def initialize board_size
      @board_size = board_size
    end

    def assign_mine_next_at
      rand(0..@board_size - 1)
    end
  end

  class PredefinedMinesAssigner
    def initialize positions
      @positions = positions.each
    end

    def assign_mine_next_at
      @positions.next
    end
  end

  class Params
    attr_reader :dim_x, :dim_y, :mines_amount

    def initialize
      with_dims 0, 0
      with_mines 0
    end

    def with_dims(x, y)
      @dim_x = x.to_i
      @dim_y = y.to_i
      @board_size = @dim_x * @dim_y
  
      self
    end
  
    def with_mines(mines_amount)
      @mines_amount = mines_amount.to_i
  
      self
    end

    def board_size
      @dim_x * @dim_y
    end
  end

  class Generator
    def initialize params, mines_assigner = nil
      @params = params
      @mines_assigner = mines_assigner || RandomMinesAssigner.new(params.board_size)

      # p @mines_assigner
    end
  
    def generate
      @tiles = Tiles.new(@params.dim_x)
      @board = Board.new(@tiles, @params.dim_x, @params.dim_y)
  
      generate_tiles
      generate_mines
      mark_tiles
  
      @board
    end
  
    private
  
    def generate_tiles
      @params.board_size.times do |i|
        @tiles << Tile.new(i)
      end
    end
  
    def generate_mines
      @params.mines_amount.times do
        loop do
          mine_place = @mines_assigner.assign_mine_next_at #rand(0..@params.board_size - 1)
  
          if @tiles[mine_place].is_mine
            next
          end
  
          @tiles[mine_place].is_mine = true
          break
        end
      end
    end
  
    def mark_tiles
      @tiles.each do |cur_tile|
        if cur_tile.is_mine
          next
        end
        neighbor_mines = 0
        @tiles.get_neighbours_of(cur_tile.num).each do |neighbor_tile|
          if neighbor_tile.is_mine
            neighbor_mines += 1
          end
        end
        cur_tile.mines_around = neighbor_mines
      end
    end
  end  
end

class GameRuntime
  def initialize(board)
    @is_live = true
    @board = board
    @action_handlers = ActionHandlerManager.new
  end

  def do_action(action)    
    unless @is_live
      raise StandardError.new('Game is over')
    end

    begin
      @action_handlers.get(action.class).handle(action, @board)
      handle_game_status
    rescue GameEndException
      @is_live = false
      raise
    end
  end

  private

  def handle_game_status
    @board.tiles.each do |tile|
      if tile.is_revealed or (tile.is_mine and tile.marked_as_mine)
        next
      end

      return
    end

    raise GameSuccessException
  end
end

class RevealTileActionHandler
  def handle(action, board)
    board.reveal_tile_at(action.x, action.y)
  end
end

class RevealTileAction
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end
end

class MarkMineActionHandler
  def handle(action, board)
    board.mark_mine_at(action.x, action.y)
  end
end

class MarkMineAction
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end
end

class ActionHandlerManager
  @@handlers = {
    RevealTileAction =>  RevealTileActionHandler,
    MarkMineAction => MarkMineActionHandler
  }

  def get(action) 
    if not @@handlers.key?(action)
      raise UndefinedActionException(action)
    end

    @@handlers[action].new
  end
end

class GameRuntimeException < StandardError
end

class GameEndException < StandardError
end

class GameOverException < GameEndException
end

class GameSuccessException < GameEndException
end

class TileNotFoundException < GameRuntimeException
end

class UndefinedActionException < GameRuntimeException
end
