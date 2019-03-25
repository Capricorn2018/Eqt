function [] = profit_ltg(a, p)
% profit_ltg 净利润（不含少数股东损益）长期增长趋势（三年单季数据回归）
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/profit_ltg.h5'];
    tgt_tag = 'profit_ltg'; 
    [S,profit_ltg] =  check_exist(tgt_file,'/profit_ltg',p,T,N);

    if S>0
        
       profit_file = [a.input_data_path,'/LTG_net_profit_excl_min_int_inc.h5'];

       profit = h5read(profit_file,'/net_profit_excl_min_int_inc');
       profit_stk = xblank(h5read(profit_file,'/stk_code'));
       profit_dt = datenum_h5(h5read(profit_file,'/date'));
       
       [~,p_i,profit_i] = intersect(p.stk_codes,profit_stk);
       [~,p_t,profit_t] = intersect(p.all_trading_dates(S:T),profit_dt);
       idx = S:T;
       p_t = idx(p_t);
       
       profit_ltg(p_t,p_i) = profit(profit_t,profit_i); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

