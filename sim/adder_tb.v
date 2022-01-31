`ifndef WIDTH 
	`define WIDTH 16 
`endif
`ifndef THE_DUT 
	`define THE_DUT carrySkip
`endif
`define VCD_FILE(x) `"results/x.vcd`"
module adder_tb();
reg clk;
reg en;
reg rst;
reg [`WIDTH-1:0] a;
reg [`WIDTH-1:0] b;
wire [`WIDTH-1:0] y;
wire carry;

`THE_DUT #(.N(`WIDTH)) dut(
	.A(a),
	.B(b),
	.Cin(1'b0),
	.Sout(y),
	.Cout(carry)
	);

always #5 clk = !clk;
integer i;
integer j;

function integer get_random;
input integer max;
begin 
	// 32 bits 
	get_random = (max/2) + $random % (max / 2) ;
end
endfunction 

initial begin: sim
	integer i,k;
	$dumpfile(`VCD_FILE(`THE_DUT));
	$dumpvars;
	//for(k=0;k<`WIDTH;k=k+1) begin
	//	$dumpvars(0,dut.pG[k]);
	//	$dumpvars(0,dut.pP[k]);
	//end
	clk = 0;
	en = 0; 
	rst = 0;
	a = 0;
	b = 0;
	#10 
	rst = 1;
	#10 
	rst = 0;
	#10 
	en = 1;

	for (i=0; i < 100; i = i + 1) begin	
		for (j=0; j < 100; j = j + 1) begin	
			a = $random;
			b = $random;
			#10;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			#10;
			`ifdef USE_MULT
			if(y != a*b) begin
			`else
			if(y != a+b) begin
			`endif
				$display("%d ns: TEST FAILED: a %d b %d y %d", $time, a, b, y);
				$finish;
			end
			$display("%d ns: a %d b %d y %d", $time, a, b, y);
		end
	end
	$display("%d ns: TEST PASSED", $time); 
	// for (i=0; i<256; i=i+1) begin
	// 	#10
	// 	a=i;
	// 	b=1;
	// 	$monitor("%d,%d,%d,%d,%d",$time,a,b,sum,carry);
	// end
	// #20
	$finish;
end
endmodule
