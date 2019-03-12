function [] = oper_margin(a, p)
% oper_margin 计算滚动12个月口径的 营业利润率
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/oper_margin.h5'];
    tgt_tag = 'oper_margin'; 
    [S,oper_margin] =  check_exist(tgt_file,'/oper_margin',p,T,N);


    if S>0
       rev_file = [a.input_data_path,'/TTM_oper_rev.h5'];
       profit_file = [a.input_data_path,'/TTM_oper_profit.h5'];


       rev = h5read(rev_file,'/oper_rev')';
       profit = h5read(profit_file,'/oper_profit')';
       oper_margin(S:T,:) = profit(S:T,:)./rev(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

