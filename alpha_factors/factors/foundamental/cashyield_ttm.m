function [] = cashyield_ttm(a, p)
% cashyield_ttm 计算滚动12个月口径的 经营现金流/总市值
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/cashyield_ttm.h5'];
%     tgt_tag = 'cashyield_ttm'; 
%     [S,cashyield_ttm] =  check_exist(tgt_file,'/cashyield_ttm',p,T,N);
%     
%     if S>0
%        cash_file = [a.input_data_path,'/TTM_net_cash_flows_oper_act.h5'];
%        cap_file = [a.input_data_path,'/tot_cap.h5'];
% 
%        cash = h5read(cash_file,'/net_cash_flows_oper_act');
%        cash_stk = h5read(cash_file,'/stk_code');
%        cash_dt = datenum_h5(h5read(cash_file,'/date'));
%        total_capital = h5read(cap_file,'/tot_cap');
%        cap_stk = h5read(cap_file,'/stk_code');
%        cap_dt = datenum_h5(h5read(cap_file,'/date'));
%        
%        [~,p_i,cash_i,cap_i] = intersect3(p.stk_codes,cash_stk,cap_stk);
%        [~,p_t,cash_t,cap_t] = intersect3(p.all_trading_dates(S:T),cash_dt,cap_dt);
%        idx = S:T;
%        p_t = idx(p_t);        
%        
%        cashyield_ttm(p_t,p_i) = cash(cash_t,cash_i)./total_capital(cap_t,cap_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/cashyield.mat'];
    if exist(tgt_file,'file')==2
        cashyield = load(tgt_file);
        dt = cashyield.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        cash = load([a.input_data_path,'/TTM_net_cash_flows_oper_act.mat']);
        cap = load([a.input_data_path,'/LR_tot_cap.mat']);
        
        cash.data = cash.data(cash.data.DATEN>dt_max,:);
        cap.data = cap.data(cap.data.DATEN>dt_max,:);
        
        append = factor_join(cash,cap,{'net_cash_flows_oper_act'},{'tot_cap'});
        
        append.data.cashyield = append.data.net_cash_flows_oper_act ...
                                            ./ append.data.tot_cap; 
                            
        append.data = append.data(:,{'DATEN','stk_num','cashyield'});

        
        if bool
            cashyield = factor_append(cashyield,append);
        else
            cashyield = append;
        end
            
        data = cashyield.data; %#ok<NASGU>
        code_map = cashyield.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end

end



