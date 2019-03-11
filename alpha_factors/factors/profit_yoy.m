function [] = profit_yoy(a, p)
% profit_yoy 净利润（不含少数股东损益）单季同比增长率
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/profit_yoy.h5'];
    tgt_tag = 'profit_yoy'; 
    [S,profit_yoy] =  check_exist(tgt_file,'/profit_yoy',p,T,N);

    if S>0
        
       profit_file = [a.input_data_path,'/YOY_net_profit_excl_min_int_inc.h5'];

       profit = h5read(profit_file,'/net_profit_excl_min_int_inc')';
       
       profit_yoy(S:T,:) = profit(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

