function [] = cashyield_ttm(a, p)
% cashyield_ttm 计算滚动12个月口径的 经营现金流/总市值
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/cashyield_ttm.h5'];
    tgt_tag = 'cashyield_ttm'; 
    [S,cashyield_ttm] =  check_exist(tgt_file,'/cashyield_ttm',p,T,N);
    
    if S>0
       cash_file = [a.input_data_path,'/TTM_net_cash_flows_per_act.h5'];
       cap_file = [a.input_data_path,'/tot_cap.h5'];

       cash = h5read(cash_file,'/net_cash_flows_per_act')';
       total_capital = h5read(cap_file,'/tot_cap')';
       cashyield_ttm(S:T,:) = cash(S:T,:)./total_capital(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end



