//-------------------------------------------------------------------------------------------------
//  Written by Arash Saifhashemi, saifhash@usc.edu
//  SystemVerilogCSP: Channel interface for modeling channel based asynchronous circuits
//  USC Asynchronous CAD/VLSI Group
//  University of Southern California
//  http://async.usc.edu
//-------------------------------------------------------------------------------------------------
`timescale 1ns/1fs
// uncomment the following line to enable stall calculation and display
//`define displayStalls 1
//uncomment the following line for automatic deadlock detection
`define detectDeadlock 1
`define defaultWatchDogTime 100ns
`define displayStalls 1

package SystemVerilogCSP;
  typedef enum {idle, r_pend, s_pend, s12m_pend} ChannleStatus;
  typedef enum {P2PhaseBD, P4PhaseBD, P1of2, P1of4} ChannelProtocol;
  typedef enum {ZERO, ONE, NUTRAL} V1of2;
  typedef logic [4] Channel1Of4 ;
endpackage : SystemVerilogCSP
//-------------------------------------------------------------------------------------------------
import SystemVerilogCSP::*;
//-------------------------------------------------------------------------------------------------
interface Channel;
  parameter SHARED = 0;
  parameter WIDTH = 9;
  parameter ChannelProtocol hsProtocol = P2PhaseBD;
  parameter NUMBER_OF_RECEIVERS = 1;
`ifdef detectDeadlock
  time lastSendEvent = 0;
  time lastReceiveEvent = 0;
`endif
  ChannleStatus status = idle;    //Stores the status of a channel
  logic req=0, ack=0, resend=1,e=1;             //Handshaking signals, resend_addr and resend_data are used to instantiate resending of packet
  logic oReq, oAck, oE;               //Shadow handshaking signals
  logic FL =1;
  logic BL =1;
  logic hsSenderPhase=1;
  logic hsReceiverPhase=1;
  logic [1:0] error_location_addr=0; // Random error location on 4 addr bits
  logic [1:0] number_of_error_addr=0; // Random error number on 4 addr bits
  logic [1:0] error_location_data=0; // Random error location on 4 data bits
  logic [1:0] number_of_error_data=0; // Random error number on 4 data bits
  logic error_transfer_type;
  
  logic [2*WIDTH-1:0] data=0, data0=0,data1=0;         //Actual data being communicated, 8 parity bits are added
  logic [2*WIDTH-1:0] oData, oData0,oData1;         //Actual data being communicated, 8 parity bits are added  
  logic _RESET = 1;
  logic parity0_addr; // 4 parity bits for address
  logic parity1_addr;
  logic parity2_addr;
  logic parity3_addr;
  logic parity0_data; // 4 parity bits for data
  logic parity1_data;
  logic parity2_data;
  logic parity3_data;
  logic [3:0] parity_check_addr;
  logic [3:0] parity_check_data;
  logic parity_check_tran;
  Channel1Of4 [((WIDTH+1)/2)-1:0] data_1of4;
  integer receiveCounter =0;
  semaphore receivers =  new(0);  //Mehrdad: It seems this semaphore is not in use
  genvar i;
  
  always @oReq		req = oReq;
  always @oAck		ack = oAck;
  always @oData 	data = oData;
  always @oData0	data0 = oData0;
  always @oData1	data1 = oData1;
  always @oE ack=~oE;
  always @ack e = ~ack;
  //always @_RESET ack=~RESET;

`ifdef detectDeadlock
  always  
  begin
      # (`defaultWatchDogTime);
     fork
      if(status==s_pend) 
      begin
          if(($time - lastSendEvent) > `defaultWatchDogTime)
          begin
            #(lastSendEvent - ($time - 2*`defaultWatchDogTime)) $display("###Deadlock Detected on %m @ %t",lastSendEvent);
            wait(0);
          end
    end
    if(status==r_pend)
    begin
          if(($time - lastReceiveEvent) > `defaultWatchDogTime)
          begin
            #(lastReceiveEvent - ($time - 2*`defaultWatchDogTime)) $display("###Deadlock Detected on %m @ %t",lastReceiveEvent);
          wait(0);
          end
    end
    join
  end
`endif
//-------------------------------------------------------------------------------------------------    
function Channel1Of4 [((WIDTH+1)/2)-1:0] SingleRailToP1of4 ();
	for (integer i = 0 ; i <= WIDTH-2 ; i+=2)
	begin
		case ({data [i+1], data[i]})
			2'b00: data_1of4[i/2] = 4'b0001;
			2'b01: data_1of4[i/2] = 4'b0010;
			2'b10: data_1of4[i/2] = 4'b0100;
			2'b11: data_1of4[i/2] = 4'b1000;
		endcase
	end
	SingleRailToP1of4 = data_1of4;
endfunction
//-------------------------------------------------------------------------------------------------    
function  logic [WIDTH-1:0] P1of4ToSingleRail ();
	for (integer i = 0 ; i <= WIDTH-2 ; i+=2)
	begin
		case ( data_1of4 [i/2])
			4'b0001: data[i/2] = 2'b00;
			4'b0010: data[i/2] = 2'b01;
			4'b0100: data[i/2] = 2'b10;
			4'b1000: data[i/2] = 2'b11;
		endcase
	end
	P1of4ToSingleRail = data_1of4;
endfunction
//-------------------------------------------------------------------------------------------------    
//Communication Action Tasks
//-------------------------------------------------------------------------------------------------
task Send (input logic[WIDTH-1:0] d);
`ifdef displayStalls
time start,stall;
start = $time;
`endif
`ifdef detectDeadlock
lastSendEvent = $time;
`endif

	if(hsProtocol == P4PhaseBD || hsProtocol == P1of2)
	begin
		if(WIDTH ==9) begin
		while(resend) begin // Resend until correct data is received
		error_location_addr=$urandom%4; // Random error location on address
		number_of_error_addr=$urandom%3; // Random number of errors on address
		error_location_data=$urandom%4; // Random error location on data
		number_of_error_data=$urandom%3; // Random number of errors data
		error_transfer_type=$urandom%2;
		data[17] = d[8]; // 1 transfer type bit
		data[16] = d[8]; // parity bit for transfer type bit error detection
		data[15] = d[7]; // 4 address bits in encoded 8-bit packet
        data[14] = d[6];
        data[13] = d[5];
        data[11] = d[4];
		data[9] = data[15] ^data[13] ^data[11]; // 4 parity bits for address EDC
        data[10] = data[15] ^data[14] ^data[11];
		data[12] = data[15] ^data[14] ^data[13]; 
		data[8] = data[15]^data[14]^data[13]^data[12]^data[11]^data[10]^data[9];
		
        data[7] = d[3]; // 4 data bits in encoded 8-bit packet
        data[6] = d[2];
        data[5] = d[1];
        data[3] = d[0];
		data[1] = data[7] ^data[5] ^data[3];// 4 parity bits for data EDC
        data[2] = data[7] ^data[6] ^data[3];
		data[4] = data[7] ^data[6] ^data[5]; 
		data[0] = data[7]^data[6]^data[5]^data[4]^data[3]^data[2]^data[1];
		
        
		case(number_of_error_data) // Insert random errors into data
		2'b00:
		begin 
			data[7:0] = data[7:0]; // No error is inserted
		end
		2'b01: // One error is inserted
		begin 
			case(error_location_data)
			2'b00:
			begin 
				data[3]= ~data[3];
			end
			2'b01:
			begin 
				data[5]= ~data[5];
			end
			2'b10:
			begin 
				data[6]= ~data[6];
			end
			2'b11:
			begin 
				data[7]= ~data[7];
			end	
			endcase
		end
		2'b10: // Two errors are inserted
		begin 
			case(error_location_data)
			2'b00:
			begin 
				fork
				data[3]= ~data[3];
				data[5]= ~data[5];
			join
			end
			2'b01:
			begin 
			fork
				data[5]= ~data[5];
				data[6]= ~data[6];
			join
			end
			2'b10:
			begin
			fork
				data[6]= ~data[6];
				data[7]= ~data[7];
			join
			end
			2'b11:
			begin 
			fork
				data[7]= ~data[7];
				data[3]= ~data[3];
			join
			end	
			endcase
		end
		endcase  
		
		case(number_of_error_addr) // Insert random errors into address
		2'b00:
		begin 
			data[15:8] = data[15:8]; // No error is inserted
		end
		2'b01: // One error is inserted
		begin 
			case(error_location_addr)
			2'b00:
			begin 
				data[11]= ~data[11];
			end
			2'b01:
			begin 
				data[13]= ~data[13];
			end
			2'b10:
			begin 
				data[14]= ~data[14];
			end
			2'b11:
			begin 
				data[15]= ~data[15];
			end	
			endcase
		end
		2'b10: // Two errors are inserted
		begin 
			case(error_location_addr)
			2'b00:
			begin 
				fork
				data[11]= ~data[11];
				data[13]= ~data[13];
			join
			end
			2'b01:
			begin 
			fork
				data[13]= ~data[13];
				data[14]= ~data[14];
			join
			end
			2'b10:
			begin
			fork
				data[14]= ~data[14];
				data[15]= ~data[15];
			join
			end
			2'b11:
			begin 
			fork
				data[15]= ~data[15];
				data[11]= ~data[11];
			join
			end	
			endcase
		end
		endcase 

		if(error_transfer_type ==1) begin
			data[17] = ~data[17];
		end
		data0 = ~data;
		data1 = data;
		req = 1;
		status = s_pend;                //Set the status to s_pend before wait
		#FL;
		end
		wait (ack == 1);
		data0 = 0;
		data1 = 0;
		req = 0;
		wait (ack == 0 );
		status = idle;
		end
		else begin
		data = d;
		data0 = ~d;
		data1 = d;
		req = 1;
		status = s_pend;                //Set the status to s_pend before wait
		wait (ack == 1 );
		data0 = 0;
		data1 = 0;
		req = 0;
		wait (ack == 0 );
		status = idle;
		end
	end
	else if (hsProtocol == P2PhaseBD )
	begin
		data = d;
		data0 =  ~d;
		req = hsSenderPhase;
		status = s_pend;                //Set the status to s_pend before wait
		wait (ack == hsSenderPhase );
		status = idle;
		hsSenderPhase = ~hsSenderPhase;
	end
`ifdef displayStalls
stall = $time - start;
if(stall != 0) $display("### %m Stalled(%d) @ %t",stall,$time);
`endif
endtask
//-------------------------------------------------------------------------------------------------
task SplitSend (input logic[WIDTH-1:0] d, input integer part, input integer FL = 0);
	case(hsProtocol)
		P1of2:	P4PhaseBD:
		begin 
			case (part)
				1: begin
					data <= #FL d;
					data0 <= #FL ~d;
					data1 <= #FL d;
					req = 1;
					status = s_pend;                //Set the status to s_pend before wait
				end
				2: begin
					wait (ack == 1 );
				end
				3: begin
					data0 = 0;
					data1 = 0;
					req = 0;
				end
				4: begin
					wait (ack == 0 );
					status = idle;
				end
			endcase
		end //P1of2, P4PhaseBD
		P2PhaseBD:
		begin
			case (part)
				1: begin
					data = d;   //Mehrdad: Do we need to have #FL  here is well?
					data0 =  ~d;
					req = hsSenderPhase;
					status = s_pend;                //Set the status to s_pend before wait
				end
				2: begin
					wait (ack == hsSenderPhase );
					status = idle;
					hsSenderPhase = ~hsSenderPhase;
				end
			endcase
		end	//P2PhaseBD
	endcase
endtask
//-------------------------------------------------------------------------------------------------
task Receive (output logic[WIDTH-1:0] d);
`ifdef displayStalls
time start,stall;
start = $time;
`endif
`ifdef detectDeadlock
lastReceiveEvent = $time;
`endif

	if (hsProtocol==P4PhaseBD || hsProtocol == P1of2)
	begin
		
		status = r_pend;
		if (hsProtocol == P1of2 )
			wait ( (&(data0 | data1)==1) );
		else
		  begin
			 wait (req == 1 );
			 if (SHARED)
			     req = 'z; // Inhibit other receivers from receiving
			end
		//d = data1;
		
		
		//If the last receiver:
		if (receiveCounter == NUMBER_OF_RECEIVERS-1)
		begin
			if(WIDTH ==9) begin
			//ack = 1; 
			while(resend) begin // Receive data until correct data is received
			#BL;
			data = data1;		
			
			parity0_data = data[7]^data[6]^data[5]^data[4]^data[3]^data[2]^data[1]; // Data parity bit calculation
			parity1_data = data[7]^data[5]^data[3];
			parity2_data = data[7]^data[6]^data[3];
			parity3_data = data[7]^data[6]^data[5];
			parity_check_data[0] = parity0_data^data[0]; // Data parity bit check
			parity_check_data[1] = parity1_data^data[1];
			parity_check_data[2] = parity2_data^data[2];
			parity_check_data[3] = parity3_data^data[4];
			
			parity0_addr = data[15]^data[14]^data[13]^data[12]^data[11]^data[10]^data[9]; // Address parity bit calculation
			parity1_addr = data[15] ^data[13] ^data[11];
			parity2_addr = data[15] ^data[14] ^data[11];
			parity3_addr = data[15] ^data[14] ^data[13];  
			parity_check_addr[0] = parity0_addr^data[8];// Address parity bit check
			parity_check_addr[1] = parity1_addr^data[9];
			parity_check_addr[2] = parity2_addr^data[10];
			parity_check_addr[3] = parity3_addr^data[12];
			
			parity_check_tran = data[16];
			case(parity_check_data)
			4'b0000:
			begin 
				case(parity_check_addr)
				4'b0000:
				begin 	
					ack =1;	
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type bit error is detected and corrected.");						
					end
					else begin											
						$display("No error is detected.");						
					end
					break;
				end
				4'b1101:
				begin
					ack =1;			
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[6] = ~d[6];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error and address error are detected and corrected.");						
					end
					else begin											
						$display("One address error is detected and corrected.");						
					end
					break;
				end
				4'b1011:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[5] = ~d[5];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error and address error are detected and corrected.");						
					end
					else begin											
						$display("One address error is detected and corrected.");					
					end
					break;
				end
				4'b0111:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[4] = ~d[4];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error and address error are detected and corrected.");						
					end
					else begin											
						$display("One address error is detected and corrected.");					
					end
					break;
				end	
				4'b1111:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[7] = ~d[7];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error and address error are detected and corrected.");						
					end
					else begin											
						$display("One address error is detected and corrected.");					
					end
					break;
				end	
				default:
				begin
					ack=0;
					resend = 1;
					$display("Two errors are detected and packet is resent");		
					
				end
				endcase
			end
			4'b1101:
			begin 
				case(parity_check_addr)
				4'b0000:
				begin 
					ack =1;	
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[2] = ~d[2];
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One address error is detected and corrected. %d", $time);					
					end
					break;
				end
				4'b1101:
				begin
					ack =1;			
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[2] = ~d[2];
					d[6] = ~d[6];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end
				4'b1011:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[2] = ~d[2];
					d[5] = ~d[5];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end
				4'b0111:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[2] = ~d[2];
					d[4] = ~d[4];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end	
				4'b1111:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[2] = ~d[2];
					d[7] = ~d[7];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end	
				default:
				begin
					ack=0;
					resend = 1;
					$display("Two errors are detected and packet is resent.");	
				end
				endcase
			end
			4'b1011:
			begin 
				case(parity_check_addr)
				4'b0000:
				begin 
					ack =1;	
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[1] = ~d[1];
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error and data error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data error is detected and corrected. %d", $time);					
					end		
					resend = 0;					
					break;
				end
				4'b1101:
				begin
					ack =1;			
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[1] = ~d[1];
					d[6] = ~d[6];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end
				4'b1011:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[1] = ~d[1];
					d[5] = ~d[5];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end
				4'b0111:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[1] = ~d[1];
					d[4] = ~d[4];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end	
				4'b1111:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[1] = ~d[1];
					d[7] = ~d[7];
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end	
				default:
				begin
					ack=0;
					resend = 1;
					$display("Two errors are detected and packet is resent.");	
				end
				endcase
			end
			4'b0111:
			begin 
				case(parity_check_addr)
				4'b0000:
				begin 
					ack =1;	
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[0] = ~d[0];
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error and data error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data error is detected and corrected. %d", $time);					
					end
					break;
				end
				4'b1101:
				begin
					ack =1;			
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[0] = ~d[0];
					d[6] = ~d[6];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end
				4'b1011:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[0] = ~d[0];
					d[5] = ~d[5];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end
				4'b0111:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[0] = ~d[0];
					d[4] = ~d[4];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end	
				4'b1111:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[0] = ~d[0];
					d[7] = ~d[7];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
				end	
				default:
				begin
					ack=0;
					resend = 1;
					$display("Two errors in address bit are detected and packet is resent.");	
				end
				endcase
			end	
			4'b1111:
			begin 
				case(parity_check_addr)
				4'b0000:
				begin 
					ack =1;	
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[3] = ~d[3];
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error and data error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data error is detected and corrected. %d", $time);					
					end
					break;
				end
				4'b1101:
				begin
					ack =1;			
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[3] = ~d[3];
					d[6] = ~d[6];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
					break;
				end
				4'b1011:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[3] = ~d[3];
					d[5] = ~d[5];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
					break;
				end
				4'b0111:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[3] = ~d[3];
					d[4] = ~d[4];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
					break;
				end	
				4'b1111:
				begin 
					ack =1;
					d= {data[17],data[15],data[14],data[13],data[11],data[7],data[6],data[5],data[3]};
					d[3] = ~d[3];
					d[7] = ~d[7];				
					resend = 0;
					if(parity_check_tran != data[17]) begin
						d[8] = ~d[8];
						$display("One transfer type error, data and address error are detected and corrected. %d", $time);						
					end
					else begin											
						$display("One data and address error are detected and corrected. %d", $time);					
					end
					break;
					break;
				end	
				default:
				begin
					ack=0;
					resend = 1;
					$display("Two errors are detected and packet is resent.");	
				end
				endcase
			end	
			default:
			begin
				ack=0;
				resend = 1;
				$display("Two errors in address bit are detected and packet is resent.");	
			end
			endcase
			
			end // End of while loop
			end
			else begin
				d = data1;
				data = data1;
				ack = 1; 
				
			end
			if (hsProtocol == P1of2)begin
				wait ( (|(data0 | data1)==0) );
			end
			else
				wait (req == 0 );
			ack = 0;
			status = idle; 
			receiveCounter=0;
			resend = 1;
			//#0;						//Release the control to other processes
		end
		else // If not the last receiver wait for other receivers to finish
		begin
			status = s12m_pend;
			receiveCounter++; 
			wait (receiveCounter ==0);	//Wait for other Receivers to finish.					
		end        
	end //P4PhaseBD or P1of2
	
	else  if (hsProtocol == P2PhaseBD)
	begin
		status = r_pend;                //Set the status to r_pend before wait
		wait (req == hsReceiverPhase );
	  if (SHARED)
		  req = 'z; // Inhibit other receivers from receiving
		d = data;    
		//Is this the last receiver? 
		if (receiveCounter == NUMBER_OF_RECEIVERS-1)
        begin
			ack = hsReceiverPhase; 
			status = idle;
			receiveCounter=0;
			#0;						//Release the control to other processes
			hsReceiverPhase=~hsReceiverPhase;
        end
		else  //Wait for all other receivers to finish receiving
        begin
			status = s12m_pend; 
			receiveCounter++; 
			wait (receiveCounter ==0 );
			#0;						//Release the control to other processes
        end
  end
`ifdef displayStalls
stall = $time - start;
if(stall != 0) $display("### %m Stalled(%d) @ %t",stall,$time);
`endif
endtask
//-------------------------------------------------------------------------------------------------
task SplitReceive (output logic[WIDTH-1:0] d, input integer part);
	case(hsProtocol)
		P1of2:
		P4PhaseBD:
		begin 
			case (part)
				1: begin
					status = r_pend;
					if (hsProtocol == P1of2 )
						wait ( (&(data0 | data1)==1) );
					else
						wait (req == 1 );
				end
				2: begin
					d = data1;
					ack = 1;  
				end
				3: begin
					if (hsProtocol == P1of2 )
						wait ( (|(data0 | data1)==0) );
					else
						wait (req == 0 );
				end 
				4:begin
					ack = 0;
					status = idle;
				end
			endcase
		end //P1of2 or P4PhaseBD
		P2PhaseBD: begin
			case (part)
				1: begin
					status = r_pend;                //Set the status to r_pend before wait
					wait (req == hsReceiverPhase );
					d = data;    
				end
				2: begin
					ack = hsReceiverPhase; 
					status = idle;  
					hsReceiverPhase = ~ hsReceiverPhase;
				end
			endcase
		end	//P2PhaseBD
	endcase
endtask
//-------------------------------------------------------------------------------------------------
task Peek (output logic[WIDTH-1:0] d);
  wait (status != idle && status != r_pend );
  d = data; 
endtask
//-------------------------------------------------------------------------------------------------
//probe_wait_input: used on an input/output port. wait until other party starts communication
task Probe_wait_input () ;
  wait (status != idle);
endtask
//-------------------------------------------------------------------------------------------------
endinterface: Channel
