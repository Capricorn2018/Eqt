function  blev(p,a)
       T = length(p.all_trading_dates );
       N = length(p.stk_codes);   
       tgt_tag = 'blev';  
       tgt_file =  [a.output_data_path,'\',tgt_tag ,'.h5'];
       [S,blev] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
       
       if S>0
           value = [a.input_data_path,'\DB\wind\ybl\AShareBalanceSheet.TOT_NON_CUR_LIAB.h5'];  
           tags = '/stk_code';
           tagn = '/TOT_NON_CUR_LIAB';
           tagr = '/report_period';

           X = load_single_value(S,T,N,p,value,tags,tagn,tagr);
           
           
           value = [a.input_data_path,'\DB\wind\ybl\AShareBalanceSheet.TOT_SHRHLDR_EQY_INCL_MIN_INT.h5'];  
           tags = '/stk_code';
           tagn = '/TOT_SHRHLDR_EQY_INCL_MIN_INT';
           tagr = '/report_period';

           Y = load_single_value(S,T,N,p,value,tags,tagn,tagr);
           
           blev(S:T,:) = X(S:T,:)./Y(S:T,:);   blev(blev==Inf)=NaN; blev(blev==-Inf)=NaN;
           blev(isnan(blev)) = 0;
           if  exist(tgt_file,'file')==2
               eval(['delete ',tgt_file]);
           end
           eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
       end
end