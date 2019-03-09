function [] = ep_sq(a, p)
% ep_sq 计算最新季报（年报）口径的单季度 earnings yield
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/ep_sq.h5'];
    tgt_tag = 'ep_sq'; 
    [S,ep_sq] =  check_exist(tgt_file,'/ep_sq',p,T,N);
    
    if S>0
       profit_file = [a.input_data_path,'/SQ_net_profit_excl_min_int_inc.h5'];
       cap_file = [a.input_data_path,'/tot_cap.h5'];

       profit = h5read(profit_file,'/net_profit_excl_min_int_inc')';
       total_capital = h5read(cap_file,'/tot_cap')';
       ep_sq(S:T,:) = profit(S:T,:)./total_capital(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end



