class Tile
  attr_reader :is_mine
  attr_reader :is_revealed
  attr_accessor :mines_around

  def initialize(num)
    @is_revealed = False
    # @type = tyle_type
    @is_mine = False
    @mines_around = 0
  end

  def is_mine= is_mine
    @is_mine = is_mine
    if is_mine
      @mines_around = -1
    end
  end

  def has_mines_around?
    @mines_around > 0
  end
end

class Tiles < Array
  def get_neighbours_of(tile_num)
    neighbours = []
    indexes = [
      tile_num - length - 1,
      tile_num - length,
      tile_num - length + 1,
      tile_num - 1,
      tile_num + 1,
      tile_num + length - 1,
      tile_num + length,
      tile_num + length + 1
    ]

    indexes.each do |index|
      if not @tiles[index].nil?
        neighbours << @tiles[index]
      end
    end
  end
end

class Board
  def initialize(tiles, dim_x, dim_y)
    @tiles = tiles
    @dim_x = dim_x
    @dim_y = dim_y
  end

  def get_tile(x, y):
    i = @dim_x * (y - 1) + x

    tile = @tiles[i]

    if tile == nil
      raise TileNotFoundException
    end
    
    tile
  end

  def reveal_tile tile
    tiles_to_check = get_neighbours_of tile
    tiles_to_check.prepend tile
    tiles_to_check.each do |neigbour_tile|
      if neigbour_tile.is_revealed?
        next
      end

      neigbour_tile.reveal

      if neigbour_tile.is_mine?
        raise Exception('Blow !!')
      end


      if neigbour_tile.has_mines_around?
        next
      end

      reveal_tile neigbour_tile      
    end
  end

  def reveal_tile_at x, y
    tile = git_tile(x, y)
    reveal_tile tile
  end
end

class BoardGenerator
  def initialize
    @tiles = Tiles.new
    with_dims 0, 0
  end

  def with_dims(x, y)
    @dim_x = d
    @dim_y = y
    @board_size = @dim_x * @dim_y
  end

  def with_mines(mines_amount)
    @mines_count = mines_amount
  end

  def generate
    board = Board.new @tiles @dim_x, @dim_y

    generate_tiles
    generate_mines
    mark_tiles

    board
  end

  private

  def generate_tiles
    (@board_size).times do |i|
      @tiles << Tile.new i
    end
  end

  def generate_mines
    @mines_amount.times do
      loop do
        mine_place = rand(0..@board_size)

        if @tiles[mine_place].is_mine
          next
        end

        @tiles[mine_place].is_mine = True
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
      @tiles.get_neighbours_of(tile.num).each do |neighbor_tile|
        if neighbor_tile.is_mine
          neighbor_mines += 1
        end
      end
      cur_tile.mines_around = neighbor_mines
    end
  end
end

class GameRuntime
  def initialize(board)
    @is_live = true
    @board = board
  end

  def do_action(action)
    # if not @is_live
    #     raise Exception.new 'Game is ended'
    # end

    # op_status = action_handlers.get(action).handle(action, @board)
    # handle_game_status op_status



    action_handlers.get(action).handle(action, @board)
    handle_game_status
  end

  private

  def handle_game_status op_status
    # player won if 
    # all tiles either revealed or marked as mines

    # if player won throw an appropriate exception
  end
end

class ActionHandlerManager
  def get(action) end

  class ReveealTileActionHandler
    def handle(action, board) 
      board.reveal_tile_at(action.x action.y)

      # begin
      #   board.reveal_tile_at(action.x action.y)
      # rescue MineBlownException
      #   return OpStatusGameOver.new 'Mine has blown'
      # end

      # return OpStatusGameProceeds.new
    end
  end

  class RevealTileAction
    def initialize(x, y) 
    end
  end

  class MarkMineActionHandler
    def handle(action, board)
      board.mark_mine_at(action.x, action.y)
    end
  end

  class MarkMineAction
    def initialize(x, y) 
    end
  end
end