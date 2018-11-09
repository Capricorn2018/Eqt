function  eroe(p,a)
       T = length(p.all_trading_dates );
       N = length(p.stk_codes);          
       tgt_tag = 'eroe';  
       tgt_file =  [a.output_data_path,'\',tgt_tag ,'.h5'];
       [S,eroe] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
       tagn = 'con_roe_roll';
       table_name = 'con_forecast_roll_stk';
       
       if S>0
           eroe = update_zyyx_tables(S,T,eroe,p,a,table_name,tagn);
           if  exist(tgt_file,'file')==2
               delete tgt_file
           end

           eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
       end

end