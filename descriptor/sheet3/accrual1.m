function  accrual1(p,a)
       T = length(p.all_trading_dates );
       N = length(p.stk_codes);   
       tgt_tag = 'accrual1';  
       tgt_file =  [a.output_data_path,'\',tgt_tag ,'.h5'];
       [S,accrual1] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
       
       if S>0
           value = [a.input_data_path,'\DB\wind\ybl\AShareTTMHis.S_FA_OP_TTM.h5'];  
           tags = '/stk_code';
           tagn = '/S_FA_OP_TTM';
           tagr = '/report_period';

           X = load_single_value(S,T,N,p,value,tags,tagn,tagr);
           
           
           value = [a.input_data_path,'\DB\wind\ybl\AShareBalanceSheet.TOT_ASSETS.h5'];  
           tags = '/stk_code';
           tagn = '/TOT_ASSETS';
           tagr = '/report_period';

           Y = load_single_value(S,T,N,p,value,tags,tagn,tagr);
           
           accrual1(S:T,:) = X(S:T,:)./Y(S:T,:);   accrual1(accrual1==Inf)=NaN; accrual1(accrual1==-Inf)=NaN;
           accrual1(isnan(accrual1)) = 0;
           
           
           if  exist(tgt_file,'file')==2
               eval(['delete ',tgt_file]);
           end
           eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
       end
end