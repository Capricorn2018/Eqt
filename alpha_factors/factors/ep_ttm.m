function [] = ep_ttm(a, p)
% ep_ttm 计算滚动12个月口径的 earnings yield
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/ep_ttm.h5'];
    tgt_tag = 'ep_ttm'; 
    [S,ep_ttm] =  check_exist(tgt_file,'/ep_ttm',p,T,N);


    if S>0
       profit_file = [a.input_data_path,'/TTM_net_profit_excl_min_int_inc.h5'];
       cap_file = [a.input_data_path,'/tot_cap.h5'];

       profit = h5read(profit_file,'/net_profit_excl_min_int_inc')';
       total_capital = h5read(cap_file,'/tot_cap')';
       ep_ttm(S:T,:) = profit(S:T,:)./total_capital(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end



