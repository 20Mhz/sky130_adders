/* PGK */

module blackCell(
	input wire  Gin_i2k,
	input wire  Pin_i2k,
	input wire  Gin_kd2j,
	input wire  Pin_kd2j,
	output wire  Gout_i2j,
	output wire  Pout_i2j
);
	assign Gout_i2j = Gin_i2k + (Pin_i2k*Gin_kd2j);
	assign Pout_i2j = Pin_i2k * Pin_kd2j ;
endmodule

module grayCell (
	input wire  Gin_i2k,
	input wire  Pin_i2k,
	input wire  Gin_kd2j,
	output wire  Gout_i2j
	);
	//assign Gout_i2j = Gin_i2k + (Pin_i2k*Gin_kd2j);
	sky130_fd_sc_hd__a21o_1 uGray(
		.A1(Pin_i2k),
		.A2(Gin_kd2j),
		.B1(Gin_i2k),
		.X(Gout_i2j)
	);
endmodule

// This computes P_4to1 and G4to:1
module pg_box #(parameter N=4) (
    input wire Cin,
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    output wire [N-1:0] G_n2j,
		output wire [N-1:0] P_n,
		output wire [N-1:0] G_n,
    output wire P_i2j 
    );
	assign G_n2j[0]=G_n[0]; // G1:1
	sky130_fd_sc_hd__and4_1 u_AND4(
		.A(P_n[0]),
		.B(P_n[1]),
		.C(P_n[2]),
		.D(P_n[3]),
		.X(P_i2j)
	);
	genvar i;
	generate 
	for (i=0;i<N; i=i+1) begin: pg
		sky130_fd_sc_hd__and2_0 uG_n(
			.A(A[i]),
			.B(B[i]),
			.X(G_n[i])
		);
		sky130_fd_sc_hd__xor2_1 uP_n(
			.A(A[i]),
			.B(B[i]),
			.X(P_n[i])
		);
		if(i!=N-1) begin:gray
		grayCell g0(
			.Gin_i2k(G_n[i]), // Gi:i
			.Pin_i2k(P_n[i]), // Pi:i
			.Gin_kd2j(G_n2j[i]),
			.Gout_i2j(G_n2j[i+1])
		);
		end
	end
	endgenerate
endmodule 

module cla_unit #(parameter N=4) (
    input wire Cin,
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    output wire [N-1:0] Sout,
    output wire Cout
    );
	wire P_i2j; // add to control carry mux
	wire G_3to0;
    wire [N-1:0] G_n2j;
    wire [N-1:0] P_n;
    wire [N-1:0] G_n;
	// Pass new Carry of P_4to1 is 0 
	sky130_fd_sc_hd__a21o_1 uA21O(
		.A1(P_i2j),
		.A2(Cin),
		.B1(G_n2j[N-1]),
		.X(Cout)
	);
	// Compute Group P and G
	pg_box #(.N(4)) uPG (
    	.Cin(Cin),
    	.A(A),
    	.B(B),
    	.P_n(P_n),
    	.G_n(G_n),
    	.G_n2j(G_n2j),
   		.P_i2j(P_i2j) 
    );
	// Compute Sum
	// PG Box now computes 4:1, but Sum uses 3:0
	wire [N-1:0] G3t0 = {G_n2j[N-2:0],Cin};
	wire [N-1:0] Pnm1 = {P_n[N-2:0],1'b0};
	genvar i;
	generate 
	for (i=0;i<N; i=i+1) begin: sum 
		sky130_fd_sc_hd__xor2_1 uS_n(
			.A(P_nm1[i]),
			.B(G3t0[i]),
			.X(Sout[i])
		);
	end
	endgenerate
endmodule

module carryLookAhead #(parameter N=16) (
    input wire Cin,
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    output wire [N-1:0] Sout,
    output wire Cout
    );
	wire [N/4+1:0] carries;
	assign carries[0] = Cin;
	assign Cout = carries[N/4];
	// Compute Sum
	genvar i;
	generate 
	for (i=1;i<=N/4; i=i+1) begin: cla 
		cla_unit #(.N(4)) u_CLA(
			.Cin(carries[i-1]),
			.A(A[4*i-1:4*i-4]),
			.B(B[4*i-1:4*i-4]),
			.Cout(carries[i]),
			.Sout(Sout[4*i-1:4*i-4])
			);
	end
	endgenerate
endmodule
