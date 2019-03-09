function [] = cash2profit(a, p)
% cash2profit �������12���¿ھ��� ��Ӫ�ֽ���/Ӫҵ����
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/cash2profit.h5'];
    tgt_tag = 'cash2profit'; 
    [S,cash2profit] =  check_exist(tgt_file,'/cash2profit',p,T,N);
    
    if S>0
       cash_file = [a.input_data_path,'/TTM_net_cash_flows_per_act.h5'];
       profit_file = [a.input_data_path,'/TTM_oper_profit.h5'];

       cash = h5read(cash_file,'/net_cash_flows_per_act')';
       profit = h5read(profit_file,'/oper_profit')';
       cash2profit(S:T,:) = cash(S:T,:)./profit(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end



