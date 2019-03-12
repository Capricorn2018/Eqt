function [] = cash2profit(a, p)
% cash2profit 计算滚动12个月口径的 经营现金流/营业利润
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/cash2profit.h5'];
    tgt_tag = 'cash2profit'; 
    [S,cash2profit] =  check_exist(tgt_file,'/cash2profit',p,T,N);
    
    if S>0
       cash_file = [a.input_data_path,'/TTM_net_cash_flows_per_act.h5'];
       profit_file = [a.input_data_path,'/TTM_oper_profit.h5'];

       cash = h5read(cash_file,'/net_cash_flows_per_act');
       cash_stk = h5read(cash_file,'/stk_code');
       cash_dt = h5read(cash_file,'/date');
       profit = h5read(profit_file,'/oper_profit');
       profit_stk = h5read(profit_file,'/stk_code');
       profit_dt = h5read(profit_file,'/date');
       
       [~,p_i,cash_i,profit_i] = intersect3(p.stk_codes,cash_stk,profit_stk);
       [~,p_t,cash_t,profit_t] = intersect3(p.all_trading_dates(S:T),cash_dt,profit_dt);
       idx = S:T;
       p_t = idx(p_t); 
       
       cash2profit(p_t,p_i) = cash(cash_t,cash_i)./profit(profit_t,profit_i); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end



