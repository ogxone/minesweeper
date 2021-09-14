class ConsoleInteractor
    def run()
        board = generate_board
        game_runtime = GameRuntime.new(board)

        render(board)

        loop do
            puts "Perform an action"
            action_data = gets
            begin
                action = create_action(action_data)
            rescue
                # todo notify invalid action, show help
                next
            end

            begin
                game_runtime.do_action(action)
            ensure
                render(board)
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

    def render(board)
    end

    def create_action(action_data)
    end
end