`default_nettype none

module top(
    // Clock driven by host microcontroller
    input wire i_clk,
    // Write enable, here implemented active high.
    // If this is high at posedge clk, data is shifted in to the operands
    input wire i_write_enable,
    // Read enable, active high
    // If high at posedge clk, shifts the high 8 bits of the last multiplier
    // output onto o_product_data
    input wire i_read_enable,
    // Reset line. Clears operands & mult block.
    input wire i_reset,
    // Mult block clock enable
    input wire i_mult_ce,
    // MCU -> FPGA data
    input wire [7:0] i_operand_data,
    // FPGA -> MCU data
    output wire [7:0] o_product_data
);


    // Two 36 bit multiplier operands
    reg [(36*2)-1:0] operands;

    // Break out each section for readability
    wire [35:0] operand_a;
    wire [35:0] operand_b;
    assign operand_a = operands[(36*1)-1:0];
    assign operand_b = operands[(36*2)-1:(36*1)];

    // Output from multiplier
    wire [71:0] mult_p;
    // Register for that data, updated if i_mult_ce = 1
    reg [71:0] output_p;

    always @(posedge i_clk) begin
        if (i_reset) begin
            operands <= 0;
        end else begin
            if (i_write_enable)
                operands <= {operands, i_operand_data[7:0]};
            if (i_read_enable)
                {o_product_data, output_p} = {output_p, 8'b0};
            if (i_mult_ce)
                output_p <= mult_p;
        end
    end

    ymult2 m (
        i_clk,
        i_mult_ce,
        i_reset,
        operand_a,
        operand_b,
        mult_p
    );

endmodule // top
