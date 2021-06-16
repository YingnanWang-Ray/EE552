`timescale 1ns/1ns
import SystemVerilogCSP::*;
module PipelineArbiter_1_1 (interface R1, interface R2,interface O,interface W1);
	logic d;
  always begin
		forever begin
	    wait((R1.status != idle)||(R2.status != idle));
	    if ((R1.status != idle) && (R2.status != idle)) begin
	      if ({$random}%2==0) begin                     // Both ports have tokens: select randomly
			fork
	        R1.Receive(d);  W1.Send(0); O.Send(1);
			join
	      end
	      else  begin
			fork
	        R2.Receive(d);  W1.Send(1); O.Send(1);
			join
	      end
	    end
	    else if (R1.status != idle) begin  // Only R1 has a token
		  fork
	      R1.Receive(d);  W1.Send(0); O.Send(1);
		  join
	      end
	    else begin // Only R2 has a token
		  fork
	      R2.Receive(d);  W1.Send(1); O.Send(1);
		  join
	    end
		end
  end
endmodule

module PipelineArbiter (interface R1, interface R2,interface W1);
	logic d;
  always begin
		forever begin
	    wait((R1.status != idle)||(R2.status != idle));
	    if ((R1.status != idle) && (R2.status != idle)) begin
	      if ({$random}%2==0) begin                     // Both ports have tokens: select randomly
	        R1.Receive(d);  W1.Send(0); 
	      end
	      else  begin
	        R2.Receive(d);  W1.Send(1); 
	      end
	    end
	    else if (R1.status != idle) begin  // Only R1 has a token
	      R1.Receive(d);  W1.Send(0); 
	      end
	    else begin // Only R2 has a token
	      R2.Receive(d);  W1.Send(1); 
	    end
		end
  end
endmodule

module PipelineArbiter_1_2 (interface R1, interface R2,interface O,interface W1);
	logic d;
  always begin
		forever begin
	    wait((R1.status != idle)||(R2.status != idle));
	    if ((R1.status != idle) && (R2.status != idle)) begin
	      if ({$random}%2==0) begin 		  // Both ports have tokens: select randomly
			fork
	        R1.Receive(d);  
			W1.Send(2);
			O.Send(1);
			join
	      end
	      else  begin
			fork
	        R2.Receive(d);  
			W1.Send(3); 
			O.Send(1);
			join
	      end
	    end
	    else if (R1.status != idle) begin		// Only R1 has a token
		  fork
	      R1.Receive(d);  
		  W1.Send(2); 
		  O.Send(1);
		  join
	      end
	    else begin		// Only R2 has a token
		  fork
	      R2.Receive(d);  
		  W1.Send(3); 
		  O.Send(1);
		  join
	    end
		end
  end
endmodule

module merge (interface inPort1,interface inPort2,interface controlPort, interface right);
  parameter FL = 2;
  parameter BL = 4;
  parameter WIDTH = 8;
 
  logic [WIDTH-1:0] data;
  logic c;


  always begin
		forever begin
			controlPort.Receive(c);
			if(c==0)
				begin
					inPort1.Receive(data);
					right.Send(data);
				end
			else if(c==1)
				begin
					inPort2.Receive(data);
					right.Send(data);
				end
		end
  end
endmodule

module four_way_merge (interface A_data,interface B_data,interface C_data,interface D_data,interface controlPort, interface out_data);
parameter FL = 2;
  parameter BL = 4;
  parameter WIDTH = 9;
 
  logic [WIDTH-1:0] data;
  logic [1:0] c;


  always begin
		forever begin
			controlPort.Receive(c);
			if(c==0)
				begin
					A_data.Receive(data);
					out_data.Send(data);
				end
			else if(c==1)
				begin
					B_data.Receive(data);
					out_data.Send(data);
				end
			else if(c==2)
				begin
					C_data.Receive(data);
					out_data.Send(data);
				end
			else if(c==3)
				begin
					D_data.Receive(data);
					out_data.Send(data);
				end
		end
  end
endmodule

module four_way_ArbiterMerge (interface A_req,interface B_req,interface C_req,interface D_req ,interface A_data, interface B_data,interface C_data,
							  interface D_data,interface out_data);
  parameter FL = 2;
  parameter BL = 4;
  parameter WIDTH = 9;
  Channel #(.WIDTH(2),.hsProtocol(P4PhaseBD)) W ();

 
  
  four_way_Arbiter #(.FL(FL), .BL(BL)) four_AR(A_req,B_req,C_req,D_req,W);
  four_way_merge   #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) M1(A_data, B_data,C_data,D_data,W,out_data);

  
endmodule

module four_way_Arbiter (interface A_req,interface B_req,interface C_req, interface D_req,interface control);
  parameter WIDTH = 9;
  parameter FL = 2;
  parameter BL = 4;
  Channel #(.WIDTH(2),.hsProtocol(P4PhaseBD)) W_level1[2:0] ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) W_level2[2:0] ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) O1[2:0] ();
  PipelineArbiter_1_1 P1(A_req,B_req,O1[1],W_level1[1]);
  PipelineArbiter_1_2 P2(C_req,D_req,O1[2],W_level1[2]);
  PipelineArbiter P3(O1[1],O1[2],W_level2[1]);
  merge #(.WIDTH(2), .FL(FL), .BL(BL)) M_AR(W_level1[1],W_level1[2],W_level2[1],control);
endmodule
