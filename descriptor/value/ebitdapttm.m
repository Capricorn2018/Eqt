function  ebitdapttm(p,a)
       T = length(p.all_trading_dates );
       N = length(p.stk_codes);          
       tgt_tag = 'ebitdapttm';  
       tgt_file =  [a.output_data_path,'\',tgt_tag ,'.h5'];
       [S,ebitdapttm] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
       
       if  S>0
           value = [a.input_data_path,'\DB\wind\AShareTTMHis.S_FA_EBITDA_TTM.h5'];  
           tags = '/stk_code';
           tagn = '/S_FA_EBITDA_TTM';
           tagr = '/report_period';

           X = load_single_value(S,T,N,p,value,tags,tagn,tagr);
           total_capital = h5read([a.input_data_path,'\fdata\base_data\capital.h5'],'/total_capital')';
           ebitdapttm(S:T,:) = X(S:T,:)./total_capital(S:T,:)*10000;

           if  exist(tgt_file,'file')==2
               eval(['delete ',tgt_file]);
           end
           eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
       end
end