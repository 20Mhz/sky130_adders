module carryRipple #(parameter N=16) (
    input wire Cin,
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    output wire [N-1:0] Sout,
    output wire Cout
    );
	wire [N:0] carries;
    genvar i;
    generate
    for (i=0;i<N; i=i+1) begin: ripple
	sky130_fd_sc_hd__fa_1 u_FA(
		.A(A[i]),
		.B(B[i]),
		.CIN(carries[i]),
		.COUT(carries[i+1]),
		.SUM(Sout[i])
	);
	end
	endgenerate
endmodule 

module carryRipple_h #(parameter N=16) (
    input wire Cin,
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    output wire [N-1:0] Sout,
    output wire Cout
    );
	wire [N:0] carries;
    genvar i;
    generate
    for (i=0;i<N; i=i+1) begin: ripple
	sky130_fd_sc_hd__fah_1 u_FA(
		.A(A[i]),
		.B(B[i]),
		.CI(carries[i]),
		.COUT(carries[i+1]),
		.SUM(Sout[i])
	);
	end
	endgenerate
endmodule 

module carryRippleN #(parameter N=16) (
    input wire Cin,
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    output wire [N-1:0] Sout,
    output wire Cout
    );
	wire [N:0] carries;
    genvar i;
    generate
    for (i=0;i<N; i=i+1) begin: ripple
	sky130_fd_sc_hd__fahcin_1 u_FA(
		.A(A[i]),
		.B(B[i]),
		.CIN(carries[i]),
		.COUT(carries[i+1]),
		.SUM(Sout[i])
	);
	end
	endgenerate
endmodule 

module carryRippleN_h #(parameter N=16) (
    input wire Cin,
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    output wire [N-1:0] Sout,
    output wire Cout
    );
	wire [N:0] carries;
    genvar i;
    generate
    for (i=0;i<N; i=i+1) begin: ripple
		if (i%2) begin
			sky130_fd_sc_hd__fahcon_1 u_FA(
				.A(A[i]),
				.B(B[i]),
				.CI(carries[i]),
				.COUT_N(carries[i+1]),
				.SUM(Sout[i])
			);
		end	
		else begin 
			sky130_fd_sc_hd__fahcin_1 u_FA(
				.A(A[i]),
				.B(B[i]),
				.CIN(carries[i]),
				.COUT(carries[i+1]),
				.SUM(Sout[i])
			);
		end
		end
	endgenerate
endmodule 

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
	sky130_fd_sc_hd__a21o_1 uA21O(
		.A1(Pin_i2k),
		.A2(Gin_kd2j),
		.B1(Gin_i2k),
		.X(Gout_i2j)
	);
endmodule

module carryRipple_pgk #(parameter N=16) (
    input wire Cin,
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    output wire [N-1:0] Sout,
    output wire Cout
    );
	wire [N:0] G_n2z; // Group Generate i:j or n:0 
	wire [N-1:0] P_n;
	wire [N-1:0] G_n;
	assign Cout = G_n2z[N]; // Ci = Gi:0
	assign G_n2z[0]=Cin; // G0:0=Cin
	genvar i;
	generate 
	for (i=0;i<N; i=i+1) begin: ripple
		//assign Sout[i] = (P_n[i]) ^ ( (i==0) ? Cin : G_n2z[i-1] ); // Si=Pi^Gi-1:0
		sky130_fd_sc_hd__xor2_1 uS_n(
			.A(P_n[i]),
			.B(G_n2z[i] ),
			.X(Sout[i])
		);
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
		grayCell g0(
			.Gin_i2k(G_n[i]), // Gi:i
			.Pin_i2k(P_n[i]), // Pi:i
			.Gin_kd2j(G_n2z[i]),
			.Gout_i2j(G_n2z[i+1])
		);
	end
	endgenerate
endmodule 
