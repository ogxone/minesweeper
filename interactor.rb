require_relative('game')

class ConsoleInteractor
    def run()
        board = generate_board
        game_runtime = GameRuntime.new(board)

        r = ConsoleRenderer.new

        screen = ConsoleScreen.new
        screen.with_board(board)
        r.render(screen)

        loop do
            # screen = ConsoleScreen.new

            puts "Perform an action"
            # action_data = gets
            action_data = 

            begin
                action = create_action(action_data)
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
        board_generator = BoardGenerator.new
 
        puts 'Enter x dim:'
        # dim_x = gets
        dim_x = 5
        puts 'Enter y dim:'
        # dim_y = gets
        dim_y = 5
        # todo validate
        board_generator.with_dims(dim_x, dim_y)

        puts 'Enter amount of mines:'
        # mines = gets
        mines = 5

        board_generator.with_mines(mines)

        board_generator.generate
    end

    # def render(console_screen)
    #     do_render_screen
    #     cls
    # end

    def create_action(action_data)
    end
end

class ConsoleScreen
    attr_reader :help, :message, :board
    def initialize
        @board = nil
        @help = nil
        @message = nil
    end
    
    def with_board board
        @board = board
    end

    def has_help help
        @help = help
    end

    def has_message message
        @message = message
    end

end

class ConsoleRenderer
    def render(console_screen)
        unless console_screen.board.nil?
            render_board(console_screen.board)
        end

        unless console_screen.help.nil?
            render_help(console_screen.help)
        end

        unless console_screen.message.nil?
            render_message(console_screen.message)
        end
    end

    private
    def render_board board
    end

    def render_help
    end

    def render_message
    end
end