function [] = roe_ttm(a, p)
% roe_ttm 计算滚动12个月口径的 ROE
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/roe_ttm.h5'];
    tgt_tag = 'roe_ttm'; 
    [S,roe_ttm] =  check_exist(tgt_file,'/roe_ttm',p,T,N);


    if S>0
       profit_file = [a.input_data_path,'/TTM_net_profit_excl_min_int_inc.h5'];
       eqy_file = [a.input_data_path,'/LR_tot_shrhldr_eqy_excl_min_int.h5'];


       profit = h5read(profit_file,'/net_profit_excl_min_int_inc')';
       eqy = h5read(eqy_file,'/tot_shrhldr_eqy_excl_min_int')';
       roe_ttm(S:T,:) = profit(S:T,:)./eqy(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

