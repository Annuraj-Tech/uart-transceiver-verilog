// =============================================================
// Module      : uart_rx
// Description : UART Receiver - 8N1 frame format
// Author      : Annuraj
// =============================================================

module uart_rx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire rst_n,
    input  wire rx,
    output reg  [7:0] rx_data,
    output reg  rx_done
);

    localparam BAUD_TICKS = CLK_FREQ / BAUD_RATE;
    localparam HALF_TICK  = BAUD_TICKS / 2;
    localparam IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;

    reg [1:0] state;
    reg [15:0] baud_cnt;
    reg [2:0] bit_idx;
    reg [7:0] data_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; rx_done <= 1'b0; baud_cnt <= 0; bit_idx <= 0;
        end else begin
            rx_done <= 1'b0;
            case (state)
                IDLE: if (rx == 1'b0) begin state <= START; baud_cnt <= 0; end
                START: begin
                    if (baud_cnt == HALF_TICK) begin baud_cnt <= 0; bit_idx <= 0; state <= DATA; end
                    else baud_cnt <= baud_cnt + 1;
                end
                DATA: begin
                    if (baud_cnt == BAUD_TICKS-1) begin
                        baud_cnt <= 0;
                        data_reg[bit_idx] <= rx;
                        if (bit_idx == 7) state <= STOP;
                        else bit_idx <= bit_idx + 1;
                    end else baud_cnt <= baud_cnt + 1;
                end
                STOP: begin
                    if (baud_cnt == BAUD_TICKS-1) begin rx_data <= data_reg; rx_done <= 1'b1; state <= IDLE; end
                    else baud_cnt <= baud_cnt + 1;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
