function  report_num_q(p,a)
       T = length(p.all_trading_dates );
       N = length(p.stk_codes);          
       tgt_tag = 'report_num_q';  
       tgt_file =  [a.output_data_path,'\',tgt_tag ,'.h5'];
       [S,report_num_q] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
       tagn = 'report_num_q';
       table_name = 'der_report_num';
       
       if S>0
           report_num_q = update_zyyx_tables(S,T,report_num_q,p,a,table_name,tagn);
           if  exist(tgt_file,'file')==2
               delete tgt_file
           end
            report_num_q(isnan(report_num_q))= 0;
           eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
       end

end