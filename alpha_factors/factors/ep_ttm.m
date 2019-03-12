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

       profit = h5read(profit_file,'/net_profit_excl_min_int_inc');
       profit_stk = h5read(profit_file,'/stk_code');
       profit_dt = datenum_h5(h5read(profit_file,'/date'));
       total_capital = h5read(cap_file,'/tot_cap');
       cap_stk = h5read(cap_file,'/stk_code');
       cap_dt = datenum_h5(h5read(cap_file,'/date'));
       
       [~,p_i,profit_i,cap_i] = intersect3(p.stk_codes,profit_stk,cap_stk);
       [~,p_t,profit_t,cap_t] = intersect3(p.all_trading_dates(S:T),profit_dt,cap_dt);
       idx = S:T;
       p_t = idx(p_t);
       
       ep_ttm(p_t,p_i) = profit(profit_t,profit_i)./total_capital(cap_t,cap_i); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end



