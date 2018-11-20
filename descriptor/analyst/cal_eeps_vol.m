function  cal_eeps_vol(p,a)
       T = length(p.all_trading_dates );
       N = length(p.stk_codes);          
       tgt_tag = 'eeps_vol';  
       tgt_file =  [a.output_data_path,'\',tgt_tag ,'.h5'];
       [S,eeps_vol] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
       
       tagn = 'eps_std';
       table_name = 'der_diver_stk';
       
       if S>0
           eeps_vol = update_zyyx_tables_inclue_con_year(S,T,eeps_vol,p,a,table_name,tagn);
           if  exist(tgt_file,'file')==2
               eval(['delete ',tgt_file]);
           end

           eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
       end
end