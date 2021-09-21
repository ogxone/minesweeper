class ConsoleInteractor
    def run()
        board = generate_board
        game_runtime = GameRuntime.new(board)

        render(ConsoleScreen.new.with_board(board))

        loop do
            screen = ConsoleScreen.new

            puts "Perform an action"
            action_data = gets

            begin
                action = create_action(action_data)
            rescue StandardError => e
                render(screen.with_message('invalied input. Message was:' + e.message).with_help.with_board(board))
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
                render(screen.with_board(board))
            end
        end
    end

    private

    def generate_board
        board_generator = BoardGenerator.new

        puts 'Enter x dim:'
        dim_x = gets
        puts 'Enter y dim:'
        dim_y = gets
        # todo validate
        board_generator.with_dims(dim_x, dim_y)

        puts 'Enter amount of mines:'
        mines = gets

        board_generator.with_mines(mines)

        board_generator.generate
    end

    def render(console_screen)
        do_render_screen
        cls
    end

    def create_action(action_data)
    end
end

class ConsoleScreen:
    attr_writer :with_help, :with_message, :with_board
    def initialize
        @with_help = False
        @with_message = nil
        @with_board = nil
    end
end