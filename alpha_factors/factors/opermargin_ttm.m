function [] = opermargin_ttm(a, p)
% opermargin_ttm 计算滚动12个月口径的 营业利润率
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/opermargin_ttm.h5'];
    tgt_tag = 'opermargin_ttm'; 
    [S,opermargin_ttm] =  check_exist(tgt_file,'/opermargin_ttm',p,T,N);


    if S>0
       rev_file = [a.input_data_path,'/TTM_oper_rev.h5'];
       profit_file = [a.input_data_path,'/TTM_oper_profit.h5'];


       rev = h5read(rev_file,'/oper_rev')';
       profit = h5read(profit_file,'/oper_profit')';
       opermargin_ttm(S:T,:) = profit(S:T,:)./rev(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

