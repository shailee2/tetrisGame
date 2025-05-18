
typedef struct packed {
        logic [3:0][9:0] relX;
        logic [3:0][9:0] relY;
    } Tetromino;
    
module game_logic
(
    input  logic        Reset,
    input  logic        frame_clk,
    input  logic [7:0]  keycode,
    output logic [9:0]  posX,
    output logic [9:0]  posY,
    output logic [9:0]  blockSize,
    output Tetromino    active_piece,
    output logic [0:19][19:0] board_out
);

    typedef struct packed {
        logic [3:0][9:0] relX;
        logic [3:0][9:0] relY;
    } Tetromino;

    logic is_game_over;

    Tetromino tetromino_set[7];

    initial begin
        tetromino_set[0].relX = '{0,0,0,1}; tetromino_set[0].relY = '{0,1,2,2}; // L
        tetromino_set[1].relX = '{1,1,1,0}; tetromino_set[1].relY = '{0,1,2,2}; // J
        tetromino_set[2].relX = '{0,1,2,3}; tetromino_set[2].relY = '{0,0,0,0}; // I
        tetromino_set[3].relX = '{0,1,2,1}; tetromino_set[3].relY = '{0,0,0,1}; // T
        tetromino_set[4].relX = '{0,1,1,2}; tetromino_set[4].relY = '{0,0,1,1}; // Z
        tetromino_set[5].relX = '{1,2,0,1}; tetromino_set[5].relY = '{0,0,1,1}; // S
        tetromino_set[6].relX = '{0,1,0,1}; tetromino_set[6].relY = '{0,0,1,1}; // O
    end

    parameter [9:0] START_X = 360;
    parameter [9:0] START_Y = 0;
    parameter [9:0] TILE_WIDTH = 20;

    parameter [9:0] MIN_X = 200;
    parameter [9:0] MAX_X = 619;
    parameter [9:0] MIN_Y = 0;
    parameter [9:0] MAX_Y = 639;

    parameter [9:0] STEP_X = 20;
    parameter [9:0] STEP_Y = 1;

    logic [9:0] dx, dy, next_dx, next_dy;
    logic [9:0] newX, newY;

    logic [9:0] tick_counter;
    logic       has_started;
    logic       can_rotate_piece;

    logic [7:0] prev_key;
    logic       right_pressed, left_pressed, rotate_pressed;
    logic [9:0] delay_counter;

    logic [2:0] piece_index, piece_selector;
    Tetromino current, rotated;

    logic [9:0] left_bound, right_bound;
    logic       allow_left, allow_right;

    logic [0:19][19:0] game_board;
    assign board_out = game_board;

    int cell_x, cell_y, tmp_x, tmp_y, down_row, col_idx, row_idx;
    int grid_origin_x, grid_origin_y;
    logic hit_bottom;
    logic [15:0] player_score;

    function logic check_collision(input logic [9:0] absX, input logic [9:0] absY, input Tetromino piece);
        logic blocked = 0;
        grid_origin_x = (absX - MIN_X) / TILE_WIDTH;
        grid_origin_y = (absY - MIN_Y) / TILE_WIDTH;
        for (int k = 0; k < 4; k++) begin
            tmp_x = grid_origin_x + piece.relX[k];
            tmp_y = grid_origin_y + piece.relY[k];
            if (tmp_x < 0 || tmp_x >= 20 || tmp_y < 0 || tmp_y >= 20 || game_board[tmp_y][tmp_x]) begin
                blocked = 1;
            end
        end
        return blocked;
    endfunction

    function Tetromino get_rotated(Tetromino src);
        Tetromino out_piece;
        for (int k = 0; k < 4; k++) begin
            out_piece.relX[k] = src.relY[k];
            out_piece.relY[k] = 3 - src.relX[k];
        end
        return out_piece;
    endfunction

    always_ff @(posedge frame_clk) begin
        if (Reset)
            piece_selector <= 3'b000;
        else
            piece_selector <= (piece_selector == 3'b111) ? 3'b000 : piece_selector + 1;
    end

    always_ff @(posedge frame_clk) begin
        if (Reset) begin
            right_pressed <= 1'b0;
            left_pressed  <= 1'b0;
            rotate_pressed <= 1'b0;
            prev_key      <= 8'h00;
            delay_counter <= 10'd0;
        end else begin
            rotate_pressed <= (keycode == 8'h52 && prev_key != 8'h52);
            right_pressed  <= (keycode == 8'h4F);
            left_pressed   <= (keycode == 8'h50);
            prev_key       <= keycode;
            if (right_pressed || left_pressed)
                delay_counter <= (delay_counter == 10'd5) ? 10'd0 : delay_counter + 1;
            else
                delay_counter <= 10'd0;
        end
    end

    always_comb begin
        current = tetromino_set[piece_index];
        next_dy = dy;
        next_dx = 10'd0;
        rotated = current;

        left_bound  = posX + current.relX[0] * TILE_WIDTH;
        right_bound = left_bound + TILE_WIDTH;
        for (int k = 1; k < 4; k++) begin
            logic [9:0] absolute_x = posX + current.relX[k] * TILE_WIDTH;
            if (absolute_x < left_bound)
                left_bound = absolute_x;
            if (absolute_x + TILE_WIDTH > right_bound)
                right_bound = absolute_x + TILE_WIDTH;
        end

        allow_left  = (left_bound - STEP_X >= MIN_X);
        allow_right = (right_bound + STEP_X <= MAX_X);

        if (rotate_pressed && piece_index != 3'd6) begin
            rotated = get_rotated(current);
            can_rotate_piece = !check_collision(posX, posY, rotated);
        end else begin
            can_rotate_piece = 1'b0;
        end

        if (has_started) begin
            if (keycode == 8'h51)
                next_dy = 10'd2;
            else if (tick_counter == 49)
                next_dy = STEP_Y;
            else
                next_dy = dy;

            if ((left_pressed && delay_counter == 10'd5) ||
                (keycode == 8'h50 && prev_key != 8'h50))
                if (allow_left && !check_collision(posX - STEP_X, posY, current))
                    next_dx = -STEP_X;

            if ((right_pressed && delay_counter == 10'd5) ||
                (keycode == 8'h4F && prev_key != 8'h4F))
                if (allow_right && !check_collision(posX + STEP_X, posY, current))
                    next_dx = STEP_X;
        end else begin
            next_dy = 10'd0;
            next_dx = 10'd0;
        end
    end

    assign active_piece = current;
    assign blockSize = TILE_WIDTH;
    assign newX = posX + next_dx;
    assign newY = posY + next_dy;

    always_ff @(posedge frame_clk) begin
        if (Reset) begin
            dy <= 10'd0;
            dx <= 10'd0;
            posY <= START_Y;
            posX <= START_X;
            has_started <= 1'b0;
            piece_index <= 3'b0;
            tick_counter <= 10'b0;
            game_board <= '0;
            player_score <= 16'd0;
        end else begin
            if (!has_started && (keycode == 8'h51 || keycode == 8'h50 ||
                                 keycode == 8'h4F || keycode == 8'h52))
                has_started <= 1'b1;

            if (has_started)
                tick_counter <= (tick_counter == 49) ? 10'b0 : tick_counter + 1;
            else
                tick_counter <= 10'b0;

            hit_bottom = check_collision(posX, posY + STEP_Y, current);

            if (hit_bottom) begin
                for (int k = 0; k < 4; k++) begin
                    int xg = ((posX - MIN_X) / TILE_WIDTH) + current.relX[k];
                    int yg = ((posY - MIN_Y) / TILE_WIDTH) + current.relY[k];
                    if (xg >= 0 && xg < 20 && yg >= 0 && yg < 20)
                        game_board[yg][xg] <= 1;
                end
                piece_index <= piece_selector;
                posX <= START_X;
                posY <= START_Y;
                dy <= 10'd0;
                dx <= 10'd0;
            end else begin
                posX <= newX;
                posY <= newY;
                dy <= next_dy;
                dx <= next_dx;
                if (rotate_pressed && can_rotate_piece && piece_index != 3'd6)
                    tetromino_set[piece_index] <= rotated;
            end

            for (row_idx = 19; row_idx >= 0; row_idx--) begin
                logic is_full = 1'b1;
                for (col_idx = 0; col_idx < 20; col_idx++) begin
                    if (game_board[row_idx][col_idx] == 1'b0)
                        is_full = 1'b0;
                    if (row_idx == 0 && game_board[row_idx][col_idx])
                        is_game_over <= 1'b1;
                end
                if (is_full) begin
                    player_score <= player_score + 16'd3;
                    for (down_row = row_idx; down_row > 0; down_row--) begin
                        for (col_idx = 0; col_idx < 20; col_idx++) begin
                            game_board[down_row][col_idx] <= game_board[down_row - 1][col_idx];
                        end
                    end
                    for (col_idx = 0; col_idx < 20; col_idx++) begin
                        game_board[0][col_idx] <= 1'b0;
                    end
                end
            end
        end
    end
endmodule

