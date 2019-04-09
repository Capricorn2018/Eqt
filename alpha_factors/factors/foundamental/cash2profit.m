function [] = cash2profit(a, p)
% cash2profit 计算滚动12个月口径的 经营现金流/营业利润
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/cash2profit.h5'];
%     tgt_tag = 'cash2profit'; 
%     [S,cash2profit] =  check_exist(tgt_file,'/cash2profit',p,T,N);
%     
%     if S>0
%        cash_file = [a.input_data_path,'/TTM_net_cash_flows_oper_act.h5'];
%        profit_file = [a.input_data_path,'/TTM_oper_profit.h5'];
% 
%        cash = h5read(cash_file,'/net_cash_flows_oper_act');
%        cash_stk = h5read(cash_file,'/stk_code');
%        cash_dt = datenum_h5(h5read(cash_file,'/date'));
%        profit = h5read(profit_file,'/oper_profit');
%        profit_stk = h5read(profit_file,'/stk_code');
%        profit_dt = datenum_h5(h5read(profit_file,'/date'));
%        
%        [~,p_i,cash_i,profit_i] = intersect3(p.stk_codes,cash_stk,profit_stk);
%        [~,p_t,cash_t,profit_t] = intersect3(p.all_trading_dates(S:T),cash_dt,profit_dt);
%        idx = S:T;
%        p_t = idx(p_t); 
%        
%        cash = cash(cash_t,cash_i);
%        profit = profit(profit_t,profit_i);
%        profit(profit<0) = NaN; % 避免分母小于0导致错误的现金流占比
%        
%        cash2profit(p_t,p_i) = cash./profit; %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/cash2profit.mat'];
    if exist(tgt_file,'file')==2
        cash2profit = load(tgt_file);
        dt = cash2profit.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        cash = load([a.input_data_path,'/TTM_net_cash_flows_oper_act.mat']);
        profit = load([a.input_data_path,'/TTM_oper_profit.mat']);
        
        cash.data = cash.data(cash.data.DATEN>dt_max,:);
        profit.data = profit.data(profit.data.DATEN>dt_max,:);
        
        append = factor_join(cash,profit,{'net_cash_flows_oper_act'},{'oper_profit'});
        
        append.data.cash2profit = append.data.net_cash_flows_oper_act ...
                                            ./ append.data.oper_profit;
                            
        append.data = append.data(:,{'DATEN','stk_num','cash2profit'});

        
        if bool
            cash2profit = factor_append(cash2profit,append);
        else
            cash2profit = append;
        end
            
        data = cash2profit.data; %#ok<NASGU>
        code_map = cash2profit.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end


end



