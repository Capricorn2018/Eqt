function [] = profit_ltg(a, p)
% profit_ltg �����󣨲��������ɶ����棩�����������ƣ����굥�����ݻع飩
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/profit_ltg.h5'];
    tgt_tag = 'profit_ltg'; 
    [S,profit_ltg] =  check_exist(tgt_file,'/profit_ltg',p,T,N);

    if S>0
        
       profit_file = [a.input_data_path,'/LTG_net_profit_excl_min_int_inc.h5'];

       profit = h5read(profit_file,'/net_profit_excl_min_int_inc')';
       
       profit_ltg(S:T,:) = profit(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

