function  ee2g(p,a)
       T = length(p.all_trading_dates );
       N = length(p.stk_codes);          
       tgt_tag = 'ee2g';  
       tgt_file =  [a.output_data_path,'\',tgt_tag ,'.h5'];
       [S,ee2g] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
       tagn = 'con_npcgrate_2y_roll';
       table_name = 'con_forecast_roll_stk';
       
       if S>0
           ee2g = update_zyyx_tables(S,T,ee2g,p,a,table_name,tagn);
           if  exist(tgt_file,'file')==2
               delete tgt_file
           end

           eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
       end

end