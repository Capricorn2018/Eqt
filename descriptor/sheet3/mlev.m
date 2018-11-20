function  mlev(p,a)
       T = length(p.all_trading_dates );
       N = length(p.stk_codes);   
       tgt_tag = 'mlev';  
       tgt_file =  [a.output_data_path,'\',tgt_tag ,'.h5'];
       [S,mlev] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
       
       if S>0
           value = [a.input_data_path,'\DB\wind\ybl\AShareBalanceSheet.TOT_NON_CUR_LIAB.h5'];  
           tags = '/stk_code';
           tagn = '/TOT_NON_CUR_LIAB';
           tagr = '/report_period';

           X = load_single_value(S,T,N,p,value,tags,tagn,tagr);
           total_capital = h5read([a.input_data_path,'\fdata\base_data\capital.h5'],'/total_capital')';
           mlev(S:T,:) = total_capital(S:T,:)*10000./X(S:T,:);
           
           
           mlev(mlev==Inf)=NaN;  
           mlev(mlev==-Inf)=NaN;
           mlev(isnan(mlev)) = 0;
           if  exist(tgt_file,'file')==2
               eval(['delete ',tgt_file]);
           end
           eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
       end
end