`timescale 1ns/1ns
  `include "/home/scf-12/ee552/proteus/pdk/proteus/svc2rtl.sv"
`E1OFN_M(2,1)
        `E1OFN_M(2,16)
        //--------RTL module--------
        module  merge_RTL    ( interface   controlPort     , interface   inPort1      , interface   inPort2      , interface   right      , input    CLK      , input    _RESET       )  ;
logic  [ inPort1        . W              -  1       : 0       ]    data    , ff$data      ;
logic    c    , ff$c      ;
always_ff  @ ( posedge  CLK         , negedge  _RESET          )
  begin
   if ( !  _RESET          )
   begin
   end
   else
   begin
    ff$data        <= data         ;
    ff$c        <= c         ;
   end
  end
  always_comb
   begin
    controlPort        . InitDo          ;
    inPort1        . InitDo          ;
    inPort2        . InitDo          ;
    right        . InitDo          ;
    right        . InitData          ;
    data        =  ff$data          ;
    c        =  ff$c          ;
    controlPort        . Receive     ( c          )      ;
    if ( c        ==  0         )
    begin
     inPort1        . Receive     ( data          )      ;
     right        . Send     ( data          )      ;
    end
    else if ( c        ==  1         )
    begin
     inPort2        . Receive     ( data          )      ;
     right        . Send     ( data          )      ;
    end
   end
   endmodule    //--------------------------
     //------Wrapper module------
     module  merge    ( e1of2_16      inPort1     , e1of2_16      inPort2      , e1of2_1      controlPort      , e1of2_16      right      , input    CLK      , input    _RESET       )  ;
rtl_interface    # ( . M    ( controlPort    .  M          ) , . N    ( controlPort    .  N          )   )  RTL_controlPort     (    )  ;
RECV_M_1ofN    # ( . M    ( controlPort    .  M          ) , . N    ( controlPort    .  N          )   )  controlPort_RECEIVE     ( controlPort    .  In         , RTL_controlPort    .  RcvOut           )  ;
rtl_interface    # ( . M    ( inPort1    .  M          ) , . N    ( inPort1    .  N          )   )  RTL_inPort1     (    )  ;
RECV_M_1ofN    # ( . M    ( inPort1    .  M          ) , . N    ( inPort1    .  N          )   )  inPort1_RECEIVE     ( inPort1    .  In         , RTL_inPort1    .  RcvOut           )  ;
rtl_interface    # ( . M    ( inPort2    .  M          ) , . N    ( inPort2    .  N          )   )  RTL_inPort2     (    )  ;
RECV_M_1ofN    # ( . M    ( inPort2    .  M          ) , . N    ( inPort2    .  N          )   )  inPort2_RECEIVE     ( inPort2    .  In         , RTL_inPort2    .  RcvOut           )  ;
rtl_interface    # ( . M    ( right    .  M          ) , . N    ( right    .  N          )   )  RTL_right     (    )  ;
SEND_M_1ofN    # ( . M    ( right    .  M          ) , . N    ( right    .  N          )   )  right_SEND     ( RTL_right    .  SndIn         , right    .  Out           )  ;
merge_RTL    merge_RTL_BODY     ( . controlPort    ( RTL_controlPort    .  RtlIn         ) , . inPort1    ( RTL_inPort1    .  RtlIn         ) , . inPort2    ( RTL_inPort2    .  RtlIn         ) , . right    ( RTL_right    .  RtlOut         ) , . CLK    ( CLK         ) , . _RESET    ( _RESET         )   )  ;
endmodule
