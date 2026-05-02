`default_nettype none

module tt_um_Terdoo_Osu (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    localparam int WORD_LENGTH  = 16;
    localparam int NEURON_COUNT = 4;

    core #(
        .WORD_LENGTH(WORD_LENGTH),
        .NEURON_COUNT(NEURON_COUNT)
    ) pattern_detector (
        .event_out(uo_out[1]),
        .spike_out(uo_out[5:2]),
        .indicator(uo_out[0]),
        .spike_in(ui_in[4]),
        .spike_pattern(ui_in[3:0]),
        .clk(clk),
        .rst(!rst_n)
    );

    assign uo_out[7:6] = 2'b0;
    assign uio_out[3:0]     = ui_in[3:0]; // switches toggle LEDS which show what the pattern to be matched is
    assign uio_out[7:4] = 4'b0;
    assign uio_oe      = 8'b1; //enable output

    wire _unused = &{ena, uio_in, ui_in[7:4], 1'b0};

endmodule
