`timescale 1ns/1ns
import SystemVerilogCSP::*;
module NOC;
  parameter FL = 4;
  parameter BL = 2;
  parameter WIDTH = 9;
  parameter addrWIDTH = 4;
  
  Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) intf  [160:0] ();
  integer r[60:0];
  integer s[60:0];
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(0), .y_value(0)) router_0_0(intf[160],intf[159], intf[152],intf[151],intf[38],intf[39],intf[32],intf[33],intf[0],intf[1]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(0), .y_value(1)) router_0_1(intf[33], intf[32],  intf[150],intf[149],intf[40],intf[41],intf[34],intf[35],intf[2],intf[3]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(0), .y_value(2)) router_0_2(intf[35], intf[34],  intf[148],intf[147],intf[42],intf[43],intf[36],intf[37],intf[4],intf[5]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(0), .y_value(3)) router_0_3(intf[37], intf[36],  intf[146],intf[145],intf[44],intf[45],intf[136],intf[135],intf[6],intf[7]);
  
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(1), .y_value(0)) router_1_0(intf[158],intf[157],intf[39], intf[38], intf[46],intf[47],intf[62],intf[63],intf[8],intf[9]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(1), .y_value(1)) router_1_1(intf[63], intf[62],  intf[41], intf[40], intf[48],intf[49],intf[64],intf[65],intf[10],intf[11]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(1), .y_value(2)) router_1_2(intf[65], intf[64],  intf[43], intf[42], intf[50],intf[51],intf[66],intf[67],intf[12],intf[13]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(1), .y_value(3)) router_1_3(intf[67], intf[66],  intf[45], intf[44], intf[52],intf[53],intf[134],intf[133],intf[14],intf[15]);
  
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(2), .y_value(0)) router_2_0(intf[156],intf[155],intf[47], intf[46],intf[54],intf[55],intf[68],intf[69],intf[16],intf[17]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(2), .y_value(1)) router_2_1(intf[69], intf[68],  intf[49], intf[48],intf[56],intf[57],intf[70],intf[71],intf[18],intf[19]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(2), .y_value(2)) router_2_2(intf[71], intf[70],  intf[51], intf[50],intf[58],intf[59],intf[72],intf[73],intf[20],intf[21]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(2), .y_value(3)) router_2_3(intf[73], intf[72],  intf[53], intf[52],intf[60],intf[61],intf[132],intf[131],intf[22],intf[23]);
  
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(3), .y_value(0)) router_3_0(intf[154],intf[153],intf[55],   intf[54],    intf[144],intf[143],intf[74],intf[75],intf[24],intf[25]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(3), .y_value(1)) router_3_1(intf[75],intf[74],    intf[57],   intf[56],    intf[142],intf[141],intf[76],intf[77],intf[26],intf[27]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(3), .y_value(2)) router_3_2(intf[77],intf[76],    intf[59],   intf[58],    intf[140],intf[139],intf[78],intf[79],intf[28],intf[29]);
  Router #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH), .FL(FL), .BL(BL), .x_value(3), .y_value(3)) router_3_3(intf[79],intf[78],    intf[61],   intf[60],    intf[138],intf[137],intf[130],intf[129],intf[30],intf[31]);
  
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(0), .y_addr(0)) client_0_0(intf[1],intf[0]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(0), .y_addr(1)) client_0_1(intf[3],intf[2]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(0), .y_addr(2)) client_0_2(intf[5],intf[4]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(0), .y_addr(3)) client_0_3(intf[7],intf[6]);
  
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(1), .y_addr(0)) client_1_0(intf[9],intf[8]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(1), .y_addr(1)) client_1_1(intf[11],intf[10]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(1), .y_addr(2)) client_1_2(intf[13],intf[12]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(1), .y_addr(3)) client_1_3(intf[15],intf[14]);
  
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(2), .y_addr(0)) client_2_0(intf[17],intf[16]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(2), .y_addr(1)) client_2_1(intf[19],intf[18]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(2), .y_addr(2)) client_2_2(intf[21],intf[20]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(2), .y_addr(3)) client_2_3(intf[23],intf[22]);
  
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(3), .y_addr(0)) client_3_0(intf[25],intf[24]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(3), .y_addr(1)) client_3_1(intf[27],intf[26]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(3), .y_addr(2)) client_3_2(intf[29],intf[28]);
  Client #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(3), .y_addr(3)) client_3_3(intf[31],intf[30]);
endmodule