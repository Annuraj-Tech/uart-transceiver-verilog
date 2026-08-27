// =============================================================
// Module      : uart_tx
// Description : UART Transmitter - 8N1 frame format
// Author      : Annuraj
// =============================================================

module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire rst_n,
    input  wire tx_start,
    input  wire [7:0] tx_data,
    output reg  tx,
    output reg  tx_busy
);

    localparam BAUD_TICKS = CLK_FREQ / BAUD_RATE;
    localparam IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;

    reg [1:0] state;
    reg [15:0] baud_cnt;
    reg [2:0] bit_idx;
    reg [7:0] data_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; tx <= 1'b1; tx_busy <= 1'b0; baud_cnt <= 0; bit_idx <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (tx_start) begin
                        data_reg <= tx_data; state <= START; tx_busy <= 1'b1; baud_cnt <= 0;
                    end
                end
                START: begin
                    tx <= 1'b0;
                    if (baud_cnt == BAUD_TICKS-1) begin baud_cnt <= 0; bit_idx <= 0; state <= DATA; end
                    else baud_cnt <= baud_cnt + 1;
                end
                DATA: begin
                    tx <= data_reg[bit_idx];
                    if (baud_cnt == BAUD_TICKS-1) begin
                        baud_cnt <= 0;
                        if (bit_idx == 7) state <= STOP;
                        else bit_idx <= bit_idx + 1;
                    end else baud_cnt <= baud_cnt + 1;
                end
                STOP: begin
                    tx <= 1'b1;
                    if (baud_cnt == BAUD_TICKS-1) begin baud_cnt <= 0; tx_busy <= 1'b0; state <= IDLE; end
                    else baud_cnt <= baud_cnt + 1;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
