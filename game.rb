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
  def initialize(tiles)
    @tiles = tiles
  end

  def get_tile(x, y):
    # thow an exception if not valid
  end

  def reveal_tile tile
    tile.reveal

    neighbours = get_neighbours_of tile
    neighbours.each do |neigbour_tile|

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

      reveal_neighbours_of neigbour_tile      
    end
  end

  # def get_neighbour(tile_num)
  #     tiles_around = []

  #     @tiles.get_neighbours_of(tile_num).
  # end
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
    board = Board.new @tiles

    generate_tiles
    generate_mines
    mark_tiles
  end

  private

  def generate_tiles
    (@board_size).times do |i|
      tiles << Tile.new i
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

  # def generate_tiles_2_dims
  #     @y.times |y_i| do
  #         @tiles[y_i] = []
  #         1.upto(@x) |x_i| do
  #             tiles[x_i][y_i] = Tile.new y_i * @dim_x + x_i
  #         end
  #     end
  # end
end

class GameRuntime
  def initialize
    @is_live = true
  end

  def do_action(action)
    # if not @is_live
    #     raise Exception.new 'Game is ended'
    # end

    op_status = action_handlers.get(action).handle(action, self.board)
    handle_game_status op_status
  end

  private

  def handle_game_status op_status
  end
end

# class Action
# end

class ActionHandlerManager
  def get(action) end

  class ReveealTileActionHandler
    def handle(action, board) 
      tile = board.get_tile(action.x, action.y)
      
      begin
        board.reveal_tile tile
      rescue MineBlownException
        return OpStatusGameOver.new 'Mine has blown'
      end
     
    end
  end

  class RevealTileAction
    def initialize(x, y) end
  end

  class MarkMineActionHandler
    def handle(action, board) end
  end

  class MarkMineAction
    def initialize(x, y) end
  end
end