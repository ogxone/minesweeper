require_relative('game')

class ConsoleInteractor
    def run()
        r = ConsoleRenderer.new
        r.cls

        board = generate_board
        action_factory = ActionFactory::Factory.new
        game_runtime = GameRuntime.new(board)

        screen = ConsoleScreen.new
        screen.with_board(board)
        r.render(screen)

        loop do
            screen = ConsoleScreen.new
            puts "\nPerform an action"
            action_data = gets

            begin
                action = action_factory.create_action(action_data)
            rescue StandardError => e
                r.render(screen.with_message('invalied input. Message was:' + e.message).with_help.with_board(board))
                next
            end

            begin
                game_runtime.do_action(action)
            rescue GameOverException
                screen.with_message('You lost')
                break
            rescue GameSuccessException
                screen.with_message('You won')
                break
            rescue GameRuntimeException => e
                screen.with_message('Runtime exception. Message was:' + e.message)
            ensure
                screen.with_board(board)
                r.render(screen)
            end 
        end
    end

    private

    def generate_board
        params = BoardGenerator::Params.new
 
        puts "Enter x dim(#{params.dim_x}):"
        dim_x = gets.chomp
        if dim_x.empty?
            dim_x = params.dim_x
        end

        puts "Enter y dim(#{params.dim_y}):"
        dim_y = gets.chomp
        if dim_y.empty?
            dim_y = params.dim_y
        end
        
        params.with_dims(dim_x, dim_y)

        puts "Enter amount of mines(#{params.mines_amount}):"
        mines = gets.chomp
        if mines.empty?
            mines = params.mines_amount
        end

        
        params.with_mines(mines)

        BoardGenerator::Generator.new(params).generate
    end

    def create_action(action_data)
    end
end

class ConsoleScreen
    attr_reader :help, :message, :board
    def initialize
        @board = nil
        @help = false
        @message = nil
    end
    
    def with_board board
        @board = board

        self
    end

    def with_help
        @help = true

        self
    end

    def with_message message
        @message = message

        self
    end

    def has_message message
        @message = message
    end
end

class ConsoleRenderer
    def render(console_screen)
        cls

        unless console_screen.board.nil?
            render_board(console_screen.board)
        end

        unless console_screen.message.nil?
            render_message(console_screen.message)
        end

        if console_screen.help
            render_help
        end
    end

    def cls
        system("clear && printf '\e[3J'")
    end

    private
    def render_board board
        render_x_scale(board.dim_x, board.dim_y)

        board.rows do |row, idx|
            render_y_scale_row(idx, board.dim_y)
            row.each do |tile|
                render_tile(tile)
            end
            print "\n"
        end
    end

    def render_x_scale dim_x, dim_y
        print " " * dim_x.to_s.length + " "
        dim_x.times do |idx|
            print "\033[0;35m#{align_scale_index(idx, dim_y)} \033[0m"
        end
        print "\n"
    end

    def render_y_scale_row idx, dim_y
        print "\033[0;35m#{align_scale_index(idx, dim_y)} \033[0m"
    end

    def align_scale_index idx, dim
        dim_len = dim.to_s.length
        idx_len = idx.to_s.length
        
        idx_pad = dim_len - idx_len

        if idx_pad > 0
            return '0' * idx_pad + idx.to_s
        end

        idx.to_s
    end

    def render_tile tile
        if tile.is_revealed
            render_revealed_tile tile
        else 
            render_unrevealed_tile tile
        end
    end   

    def render_unrevealed_tile tile
        if tile.marked_as_mine
            print "\033[0;35m M \033[0m"
        else
            print ' x '
        end
    end

    def render_revealed_tile tile
        if tile.is_mine
            print "\033[0;34m * \033[0m"
        elsif tile.mines_around == 0
            print "\033[0;37m - \033[0m"
        elsif tile.mines_around == 1
            print "\033[0;32m #{tile.mines_around} \033[0m"
        elsif tile.mines_around == 2
            print "\033[0;33m #{tile.mines_around} \033[0m"
        elsif tile.mines_around == 3
            print "\033[0;36m #{tile.mines_around} \033[0m"
        elsif tile.mines_around == 4
            print "\033[0;33m #{tile.mines_around} \033[0m"
        else
            print "\033[0;31m #{tile.mines_around} \033[0m"
        end
    end

    def render_help
        print <<-HELP
Use one of the awailable coomands:

1.
rev <coord_x> <coord_y> 

Reveals given tile

Example: 
rev 34, 23

2.
mine <coord_x> <coord_y>

Marks tile as mine

Example:
mine 32, 2

HELP
        
    end

    def render_message message
        print "\n"
        print "ERROR: "
        print message
        print "\n\n"
    end
end

module ActionFactory
    class AbstractActionFactory
        def create_action args
            do_create_action(parse_args(args))    
        end

        protected

        def parse_args args
            parse_coord_args(args)
        end

        def parse_coord_args args
            x, y = args.split(%r{\s+}, 2)
            [x.to_i, y.to_i]
        end
    end

    class RevealTileActionFactory < AbstractActionFactory
        def do_create_action args
            RevealTileAction.new(*args)
        end
    end

    class FactoryNotDefinedException < StandardError
    end

    class MarkMineActionFactory < AbstractActionFactory
        def do_create_action args
            MarkMineAction.new(*args)
        end
    end

    class Factory
        @@factories = {
            'mine' => MarkMineActionFactory,
            'rev' => RevealTileActionFactory
        }

        def create_action args
            action, args = split_args(args)
            if @@factories.key?(action) 
                return @@factories[action].new.create_action(args)
            end 

            raise FactoryNotDefinedException.new("Factory not defined for action `#{action}`")
        end 

        private

        def split_args args
            args.split(%r{\s+}, 2)
        end
    end
end