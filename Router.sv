`timescale 1ns/1ns
import SystemVerilogCSP::*;
module RouterLogic(interface up_left_req, interface up_right_req,  interface up_down_req,   interface up_client_req , interface up_left_data,   interface up_right_data,  interface up_down_data,  interface up_client_data  , interface up_in,
                   interface left_up_req, interface left_right_req,interface left_down_req, interface left_client_req,interface left_up_data,   interface left_right_data,interface left_down_data,interface left_client_data ,interface left_in,
                   interface right_up_req,interface right_left_req,interface right_down_req,interface right_client_req,interface right_up_data,  interface right_left_data,interface right_down_data,interface right_client_data,interface right_in,
				   interface down_up_req, interface down_left_req, interface down_right_req,interface down_client_req,interface down_up_data,   interface down_left_data, interface down_right_data,interface down_client_data,interface down_in,
				   interface client_up_req,interface client_left_req,interface client_right_req,interface client_down_req,interface client_up_data,interface client_left_data,interface client_right_data,interface client_down_data,interface client_in
				   );
  
  parameter WIDTH = 9;
  parameter addrWIDTH = 4;
  parameter FL = 2;
  parameter BL = 4;
  
  parameter [addrWIDTH/2-1 : 0] x_value;
  parameter [addrWIDTH/2-1 : 0] y_value;
  
  logic [WIDTH-1:0] up_data_in, left_data_in, right_data_in, down_data_in ,client_data_in;
  logic [addrWIDTH/2-1 : 0] x_dest, y_dest;
  
  
  integer i,j,k;
  
  always begin
	up_in.Receive(up_data_in);
	x_dest = up_data_in[WIDTH-2:WIDTH-3];
	y_dest = up_data_in[WIDTH-4:WIDTH-5];
	 
    if(x_dest < x_value) 
		begin
			fork
			left_up_req.Send(1);
			left_up_data.Send(up_data_in);
			join
			$display("data = %b from up to left", up_data_in);
        end
    else if (x_dest > x_value)
		begin
			fork
			right_up_req.Send(1);
			right_up_data.Send(up_data_in);
			join
			$display("data = %b from up to right", up_data_in);
        end
	else if (x_dest == x_value)
		begin
			if (y_dest > y_value)
			begin
				fork
				down_up_req.Send(1);
				down_up_data.Send(up_data_in);
				join
				$display("data = %b from up to down", up_data_in);
			end
			if (y_dest == y_value)
			begin
				fork
				client_up_req.Send(1);
				client_up_data.Send(up_data_in);
				join
				$display("data = %b from up to client", up_data_in);
			end
        
        end

  end
  
  always begin
	left_in.Receive(left_data_in);
	x_dest = left_data_in[WIDTH-2:WIDTH-3];
	y_dest = left_data_in[WIDTH-4:WIDTH-5];
	  
   
    if (x_dest > x_value)
		begin
			fork
			right_left_req.Send(1);
			right_left_data.Send(left_data_in);
			join
			$display("data = %b from left to right", left_data_in);
        end
		
	else if (x_dest == x_value)
		begin
			if (y_dest > y_value)
			begin
				fork
				down_left_req.Send(1);
				down_left_data.Send(left_data_in);
				join
				$display("data = %b from left to down", left_data_in);
			end
			
			if (y_dest < y_value)
			begin
			fork
				up_left_req.Send(1);
				up_left_data.Send(left_data_in);
				join
				$display("data = %b from left to up", left_data_in);
			end
			
			if (y_dest == y_value)
			begin
			fork
				client_left_req.Send(1);
				client_left_data.Send(left_data_in);
				join
				$display("data = %b from left to client", left_data_in);
			end
        
        end

  end
  
  always begin
	right_in.Receive(right_data_in);
	x_dest = right_data_in[WIDTH-2:WIDTH-3];
	y_dest = right_data_in[WIDTH-4:WIDTH-5];
	  
   
    if (x_dest < x_value)
		begin
		fork
			left_right_req.Send(1);
			left_right_data.Send(right_data_in);
			join
			$display("data = %b from right to left", right_data_in);
        end
		
	else if (x_dest == x_value)
		begin
			if (y_dest > y_value)
			begin
			fork
				down_right_req.Send(1);
				down_right_data.Send(right_data_in);
				join
				$display("data = %b from right to down", right_data_in);
			end
			
			if (y_dest < y_value)
			begin
			fork
				up_right_req.Send(1);
				up_right_data.Send(right_data_in);
				join
				$display("data = %b from right to up", right_data_in);
			end
			
			if (y_dest == y_value)
			begin
			fork
				client_right_req.Send(1);
				client_right_data.Send(right_data_in);
				join
				$display("data = %b from right to client", right_data_in);
			end
        
        end

  end
  
  always begin
	down_in.Receive(down_data_in);
	x_dest = right_data_in[WIDTH-2:WIDTH-3];
	y_dest = right_data_in[WIDTH-4:WIDTH-5];
	  
   
    if (x_dest < x_value)
		begin
		fork
			left_down_req.Send(1);
			left_down_data.Send(down_data_in);
			join
			$display("data = %b from down to left", down_data_in);
        end
	
	else if (x_dest > x_value)
		begin
		fork
			right_down_req.Send(1);
			right_down_data.Send(down_data_in);
			join
			$display("data = %b from down to right", down_data_in);
        end
		
	else if (x_dest == x_value)
		begin
			
			
			if (y_dest < y_value)
			begin
			fork
				up_down_req.Send(1);
				up_down_data.Send(down_data_in);
				join
				$display("data = %b from down to up", down_data_in);
			end
			
			if (y_dest == y_value)
			begin
			fork
				client_down_req.Send(1);
		
				client_down_data.Send(down_data_in);
				join
				$display("data = %b from down to client", down_data_in);
			end
        
        end

  end
  
  always begin
	client_in.Receive(client_data_in);
	x_dest = client_data_in[WIDTH-2:WIDTH-3];
	y_dest = client_data_in[WIDTH-4:WIDTH-5];
	  
   
    if (x_dest < x_value)
		begin
		fork
			left_client_req.Send(1);
			left_client_data.Send(client_data_in);
			join
			$display("data = %b from client to left", client_data_in);
        end
	
	else if (x_dest > x_value)
		begin
		fork
			right_client_req.Send(1);
			right_client_data.Send(client_data_in);
			join
			$display("data = %b from client to right", client_data_in);
        end
		
	else if (x_dest == x_value)
		begin
			
			
			if (y_dest < y_value)
			begin
			fork
				up_client_req.Send(1);
				up_client_data.Send(client_data_in);
				join
				$display("data = %b from client to up", client_data_in);
			end
			
			/*if (y_dest == y_value)
			begin
				
				client_out.Send(client_data_in);
			end*/
			
			if (y_dest > y_value)
			begin
			fork
				down_client_req.Send(1);
				down_client_data.Send(client_data_in);
				join
				$display("data = %b from client to down", client_data_in);
			end
        end

  end
  
  
endmodule

module Router(interface up_in, interface up_out, interface left_in,interface left_out,interface right_in,interface right_out,interface down_in, interface down_out,interface client_in,interface client_out);
  parameter FL = 2;
  parameter BL = 4;
  parameter WIDTH = 9;
  parameter addrWIDTH = 4;
  parameter x_value;
  parameter y_value;
  
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) up_left_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) up_right_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) up_down_data ();
   Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) up_client_data ();
  
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) left_up_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) left_right_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) left_down_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) left_client_data ();
  
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) right_up_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) right_left_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) right_down_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) right_client_data ();
  
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) down_up_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) down_left_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) down_right_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) down_client_data ();
  
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) client_up_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) client_left_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) client_right_data ();
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) client_down_data ();

  
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) up_left_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) up_right_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) up_down_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) up_client_req ();
  
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) left_up_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) left_right_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) left_down_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) left_client_req ();
  
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) right_up_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) right_left_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) right_down_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) right_client_req ();
  
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) down_up_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) down_left_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) down_right_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) down_client_req ();
  
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) client_up_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) client_left_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) client_right_req ();
  Channel #(.WIDTH(1),.hsProtocol(P4PhaseBD)) client_down_req ();
  
  RouterLogic #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(x_value), .y_value(y_value)) R( up_left_req,   up_right_req,    up_down_req,      up_client_req,   up_left_data,  up_right_data,   up_down_data,      up_client_data ,  up_in,
																					left_up_req,   left_right_req,  left_down_req,    left_client_req, left_up_data,  left_right_data, left_down_data,    left_client_data, left_in,
																					right_up_req,  right_left_req,  right_down_req,   right_client_req,right_up_data, right_left_data, right_down_data,   right_client_data,right_in,
																					down_up_req,   down_left_req,   down_right_req,   down_client_req, down_up_data,  down_left_data,  down_right_data,   down_client_data, down_in,
																					client_up_req, client_left_req, client_right_req, client_down_req, client_up_data,client_left_data,client_right_data, client_down_data, client_in);
  
  four_way_ArbiterMerge #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) AM0( up_left_req,  up_right_req,   up_down_req,  up_client_req ,    up_left_data,  up_right_data,   up_down_data, up_client_data ,    up_out);
  four_way_ArbiterMerge #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) AM1( left_up_req,  left_right_req, left_down_req , left_client_req, left_up_data,  left_right_data, left_down_data ,left_client_data, left_out);
  four_way_ArbiterMerge #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) AM2( right_up_req, right_left_req, right_down_req, right_client_req,right_up_data, right_left_data, right_down_data,right_client_data,right_out);
  four_way_ArbiterMerge #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) AM3( down_up_req,  down_left_req,  down_right_req, down_client_req ,down_up_data , down_left_data , down_right_data,down_client_data, down_out);
  four_way_ArbiterMerge #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) AM4( client_up_req, client_left_req,  client_right_req, client_down_req ,client_up_data , client_left_data , client_right_data,client_down_data, client_out);
endmodule
