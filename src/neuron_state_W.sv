module neuron_state_W #(parameter int M = 4, W = 4)
(
    output logic signed [W-1:0] dout,
    input  logic signed [W-1:0] din,
    input  logic [$clog2(M)-1:0] addr,
    input  logic we,
    input  logic clk,
    input  logic rst
);

    logic signed [W-1:0] membranes[M-1:0];

    localparam int MIN_VAL = -(1 << (W-1));
    localparam int MAX_VAL =  (1 << (W-1)) - 1;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 1; i <= M; i++) begin
                int init_val;
                init_val = MIN_VAL + (((MAX_VAL - MIN_VAL) * i) / M);
                membranes[i-1] <= signed'(init_val[W-1:0]);
            end

            dout <= '0;
        end else begin
            if (we)              // we = 1 is a reading operation
                dout <= membranes[addr];
            else                 // we = 0 is a writing operation
                membranes[addr] <= din;
        end
    end

endmodule