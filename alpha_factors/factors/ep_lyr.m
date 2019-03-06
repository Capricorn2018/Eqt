function [] = ep_lyr(a, p)
% EP_LYR
% p.all_trading_dates里面存了需要的日期
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'\ep_lyr.h5'];
    tgt_tag = 'ep_lyr'; 
    [S,ep_lyr] =  check_exist(tgt_file,'/ep_lyr',p,T,N);


    if S>0
       profit_file = [a.input_data_path,'LYR_net_profit_excl_min_int_inc.h5'];
       cap_file = [a.input_data_path,'total_capital.h5'];


       profit = h5read(profit_file,'/net_profit_excl_min_int_inc')';
       total_capital = h5read(cap_file,'/total_capital')';
       ep_lyr(S:T,:) = profit(S:T,:)./total_capital(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

