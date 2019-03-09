function [] = roa_ttm(a, p)
% roa_ttm 计算滚动12个月口径的 ROE
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/roa_ttm.h5'];
    tgt_tag = 'roa_ttm'; 
    [S,roa_ttm] =  check_exist(tgt_file,'/roa_ttm',p,T,N);


    if S>0
       profit_file = [a.input_data_path,'/TTM_net_profit_excl_min_int_inc.h5'];
       asset_file = [a.input_data_path,'/LR_tot_assets.h5'];


       profit = h5read(profit_file,'/net_profit_excl_min_int_inc')';
       asset = h5read(asset_file,'/tot_assets')';
       roa_ttm(S:T,:) = profit(S:T,:)./asset(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

