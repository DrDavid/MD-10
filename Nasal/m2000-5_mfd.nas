#scripts mfd

var RMI1prop="instrumentation/mfd/rmi-1-src";
var RMI2prop="instrumentation/mfd/rmi-2-src";
var RMI1src="instrumentation/mfd/rmi-1-bearing-deg";
var RMI2src="instrumentation/mfd/rmi-2-bearing-deg";
var RMI1ident="instrumentation/mfd/rmi-1-ident";
var RMI2ident="instrumentation/mfd/rmi-2-ident";
var RMI1dist="instrumentation/mfd/rmi-1-dist";
var RMI2dist="instrumentation/mfd/rmi-2-dist";

var count_2=0;
var count_3=0;

#setlistener("/sim/signals/fdm-initialized", func {
#    print("MFD ...Check");
#    settimer(update_main, 5.0);
#});


########### RMI RADIO MAGNETIC INDICATOR#################

########### Update RMI 1

var update_rmi1=func{
    var rmi1_src=getprop(RMI1prop);
    if(rmi1_src==""){
        setprop(RMI1ident,"");
        setprop(RMI1dist,0);
        }
    if(rmi1_src=="NAV1"){
       setprop(RMI1src,getprop("instrumentation/nav/heading-deg"));
       if(getprop("instrumentation/nav/nav-id") != nil){setprop(RMI1ident,getprop("instrumentation/nav/nav-id"));}
       if(getprop("instrumentation/nav/dme-in-range")){
           var rmi1_dist=getprop("instrumentation/nav/nav-distance");
           rmi1_dist=rmi1_dist/1852;
           setprop(RMI1dist,rmi1_dist);
           }
    }
    if(rmi1_src=="TACAN"){
       setprop(RMI1src,getprop("instrumentation/tacan/indicated-bearing-true-deg"));
       setprop(RMI1ident,getprop("instrumentation/tacan/ident"));
       setprop(RMI1dist,getprop("instrumentation/tacan/indicated-distance-nm"));
       }
    if(rmi1_src=="ADF2"){
        var adf2_corr=getprop("instrumentation/adf[1]/indicated-bearing-deg");
       adf2_corr=adf2_corr+getprop("orientation/heading-deg");
       if(adf2_corr>360)adf2_corr-=360;
       setprop(RMI1src,adf2_corr);       
       setprop(RMI1ident,getprop("instrumentation/adf[1]/ident"));
       setprop(RMI1dist,0);
       }      
}

########### Update RMI 2
var update_rmi2 = func{
        var rmi2_src=getprop(RMI2prop);
    if(rmi2_src==""){
        setprop(RMI2ident,"");
        setprop(RMI2dist,0);
        }       

    if(rmi2_src=="NAV2"){
       setprop(RMI2src,getprop("instrumentation/nav[1]/heading-deg"));
       setprop(RMI2ident,getprop("instrumentation/nav[1]/nav-id"));       
       if(getprop("instrumentation/nav[1]/dme-in-range")){
           var rmi2_dist=getprop("instrumentation/nav[1]/nav-distance");
           rmi2_dist=rmi2_dist/1852;
           setprop(RMI2dist,rmi2_dist);
           }
       }
    if(rmi2_src=="ADF1"){
       var adf1_corr=getprop("instrumentation/adf/indicated-bearing-deg");
       adf1_corr=adf1_corr+getprop("orientation/heading-deg");
       if(adf1_corr>360)adf1_corr-=360;
       setprop(RMI2src,adf1_corr);
       setprop(RMI2ident,getprop("instrumentation/adf/ident"));
       setprop(RMI2dist,0);
       }
}


########### Bouton RMI 1
var rmi1_src_set=func(){  
    count_2+=1;
    if(count_2>3)count_2=0;    
    if(count_2==0){
        setprop(RMI1prop,"");
        update_rmi1();
        }
    if(count_2==1){
        setprop(RMI1prop,"NAV1");
        update_rmi1();
        }       
    if(count_2==2){
        setprop(RMI1prop,"TACAN"); 
        update_rmi1();
        }      
    if(count_2==3){
        setprop(RMI1prop,"ADF2"); 
        update_rmi1();
        }       
}

############ Bouton RMI 2
var rmi2_src_set=func(){    
    count_3+=1;
    if(count_3>2)count_3=0;    
    if(count_3==0){
        setprop(RMI2prop,"");
        update_rmi2();
        }       
    if(count_3==1){
        setprop(RMI2prop,"NAV2");
        update_rmi2();
        }       
    if(count_3==2){
        setprop(RMI2prop,"ADF1");
        update_rmi2();
        }         
}

########### RMU RADIO MANAGEMENT UNIT####################

###########   Swap frequences COMM et NAV
var frequ_swapL =func(){
          var stb = "";
          var sel = "";

          var rmu_L = getprop("instrumentation/mfd/rmuL");
         
          var swp=func{            
            var stb_x = getprop(stb);            
            setprop(stb,getprop(sel));
            setprop(sel,stb_x);            
            } 

          if(rmu_L==1){
              stb="instrumentation/comm/frequencies/standby-mhz";
              sel="instrumentation/comm/frequencies/selected-mhz";
              swp();
              }
          if(rmu_L==2){
              stb="instrumentation/comm[1]/frequencies/standby-mhz";
              sel="instrumentation/comm[1]/frequencies/selected-mhz";
              swp();
              }
          if(rmu_L==3){
              stb="instrumentation/nav/frequencies/standby-mhz";
              sel="instrumentation/nav/frequencies/selected-mhz";
              swp();
              }
          if(rmu_L==4){
              stb="instrumentation/nav[1]/frequencies/standby-mhz";
              sel="instrumentation/nav[1]/frequencies/selected-mhz";
              swp();
              }
                    
}

###########   Swap frequences ADF et TACAN
var frequ_swapR=func(){
          var stb = "";
          var sel = "";

          var rmu_R = getprop("instrumentation/mfd/rmuR");
         
          var swp=func{            
            var stb_x = getprop(stb);            
            setprop(stb,getprop(sel));
            setprop(sel,stb_x);            
            } 

          var swp_tacan=func{
            var stb_x = getprop(stb);           
            setprop(stb,getprop(sel));
            setprop(sel,stb_x);
            stb="instrumentation/tacan/frequencies/stby-can2";              
            sel="instrumentation/tacan/frequencies/selected-channel[4]";
            var stb_y = getprop(stb);            
            setprop(stb,getprop(sel));
            setprop(sel,stb_y);            
            }           

          if(rmu_R==1){
              stb="instrumentation/adf/frequencies/standby-khz";
              sel="instrumentation/adf/frequencies/selected-khz"; 
              swp(); 
              }
          if(rmu_R==2){
              stb="instrumentation/adf[1]/frequencies/standby-khz";
              sel="instrumentation/adf[1]/frequencies/selected-khz";
              swp(); 
              }
          if(rmu_R==3){
              stb="instrumentation/tacan/frequencies/stby-can";              
              sel="instrumentation/tacan/frequencies/selected-channel";             
              swp_tacan(); 
              }
        
}

########### Ajustage frequences ADF et TACAN

 var frequ_adjustR=func(dir){
     var amt=0;
     var sign="";
     var frequ="";     
     var rmuR=getprop("instrumentation/mfd/rmuR");     

     var adj_adf=func(){
        amt=getprop(frequ)+(dir);
        amt=(amt< 180 ? 180 : amt> 1750 ? 1750 : amt);
        setprop(frequ,amt);
        }

     var adj_tacan=func(){
        amt=getprop(frequ)+(dir/10);
        amt=(amt< 17 ? 17 : amt> 126 ? 126 : amt);
        setprop(frequ,amt);
        }

     var adj_tacan_sign=func{
        sign=getprop(frequ);
        if(sign=="X")sign="Y";
        else sign="X";
        setprop(frequ,sign);
        }     

     if(rmuR==1){
        frequ="instrumentation/adf/frequencies/standby-khz";
        adj_adf();
        } 
     if(rmuR==2){
        frequ="instrumentation/adf[1]/frequencies/standby-khz"; 
        adj_adf();
        }
     if(rmuR==3){
        if(dir==1 or dir==-1){
           frequ="instrumentation/tacan/frequencies/stby-can2";
           adj_tacan_sign();
           }
        else{frequ="instrumentation/tacan/frequencies/stby-can";         
        adj_tacan();
        }        
        }
 }

############ Ajustage frequences COMM et NAV

var frequ_adjustL=func(dir){
     var amt=0;
     var frequ="";
     var rmuL=getprop("instrumentation/mfd/rmuL");    
     
     var adj_frequ=func(){
        amt=getprop(frequ)+(dir);        
        if(rmuL==1 or rmuL==2)
        amt=(amt< 118.00 ? 118.00 : amt> 144.00 ? 144.00 : amt);
        if(rmuL==3 or rmuL==4)
        amt=(amt< 108.00 ? 108.00 : amt> 117.95 ? 117.95 : amt);       
        setprop(frequ,amt);
        }

     if(rmuL==1){
        frequ="instrumentation/comm/frequencies/standby-mhz";
        adj_frequ();
        } 
     if(rmuL==2){
        frequ="instrumentation/comm[1]/frequencies/standby-mhz"; 
        adj_frequ();
        }
     if(rmuL==3){
        frequ="instrumentation/nav/frequencies/standby-mhz";
        adj_frequ();
        } 
     if(rmuL==4){
        frequ="instrumentation/nav[1]/frequencies/standby-mhz"; 
        adj_frequ();
        }
 }

########## Main Loop
var update_main=func(){
    update_rmi1();
    update_rmi2();    
#settimer(update_main,0.25);
}

