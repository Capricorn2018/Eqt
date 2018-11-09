function  eeg(p,a)
       T = length(p.all_trading_dates );
       N = length(p.stk_codes);          
       tgt_tag = 'eeg';  
       tgt_file =  [a.output_data_path,'\',tgt_tag ,'.h5'];
       [S,eeg] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
       tagn = 'con_np_yoy_roll';
       table_name = 'con_forecast_roll_stk';
       
       if S>0
           eeg = update_zyyx_tables(S,T,eeg,p,a,table_name,tagn);
           if  exist(tgt_file,'file')==2
               eval(['delete ',tgt_file]);
           end

           eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
       end

end