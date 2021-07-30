
class Tile
    def initialize(num)
        @is_revealed = False
        @type = tyle_type
    end
end

class Board
    def initialize(tiles)
    end
end

class BoardGenerator
    def initialize
        @tiles = []
    end

    def with_dims(x, y)
        @dim_x = d
        @dim_y = y
    end

    def with_mines(mines_amount)
        @mines_count = mines_amount
    end

    def create
        generate_tiles
        generate_mines
        mark_tiles
    end

    def generate_tiles
        @y.times |y_i| do
            @tiles[y_i] = []
            1.upto(@x) |x_i| do
                tiles[x_i][y_i] = Tile.new y_i * @dim_x + x_i
            end
        end
    end
end

class GameRuntime
    def initialize
        @is_live = true
    end

    def do_action(action):
        # if not @is_live
        #     raise Exception.new 'Game is ended'
        # end

        game_status = action_handlers.get(action).handle(action, self.board)
        handle_game_status game_status
    end
    
    def handle_game_status
    end
end

# class Action
# end

class ActionHandlerManager
    def get(action)
end

class ReavealTileActionHandler
    def handle(action, board)
    end
end

class RevealTileAction
    def initialize(x, y)
    end
end

class MarkMineActionHandler
    def handle(action, board)
    end
end

class MarkMineAction
    def initialize(x, y)
    end
end