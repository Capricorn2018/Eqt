function [] = ep_ttm(a, p)
% ep_ttm 计算滚动12个月口径的 earnings yield
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/ep_ttm.h5'];
%     tgt_tag = 'ep_ttm'; 
%     [S,ep_ttm] =  check_exist(tgt_file,'/ep_ttm',p,T,N);
% 
% 
%     if S>0
%        profit_file = [a.input_data_path,'/TTM_net_profit_excl_min_int_inc.h5'];
%        cap_file = [a.input_data_path,'/tot_cap.h5'];
% 
%        profit = h5read(profit_file,'/net_profit_excl_min_int_inc');
%        profit_stk = h5read(profit_file,'/stk_code');
%        profit_dt = datenum_h5(h5read(profit_file,'/date'));
%        total_capital = h5read(cap_file,'/tot_cap');
%        cap_stk = h5read(cap_file,'/stk_code');
%        cap_dt = datenum_h5(h5read(cap_file,'/date'));
%        
%        [~,p_i,profit_i,cap_i] = intersect3(p.stk_codes,profit_stk,cap_stk);
%        [~,p_t,profit_t,cap_t] = intersect3(p.all_trading_dates(S:T),profit_dt,cap_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        ep_ttm(p_t,p_i) = profit(profit_t,profit_i)./total_capital(cap_t,cap_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/ep_ttm.mat'];
    if exist(tgt_file,'file')==2
        ep_ttm = load(tgt_file);
        dt = ep_ttm.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        profit = load([a.input_data_path,'/TTM_net_profit_excl_min_int_inc.mat']);
        cap = load([a.input_data_path,'/LR_tot_cap.mat']);
        
        profit.data = profit.data(profit.data.DATEN>dt_max,:);
        cap.data = cap.data(cap.data.DATEN>dt_max,:);
        
        append = factor_join(profit,cap,{'net_profit_excl_min_int_inc'},{'tot_cap'});
        
        append.data.ep_ttm = append.data.net_profit_excl_min_int_inc ...
                                ./ append.data.tot_cap;
                            
        append.data = append.data(:,{'DATEN','stk_num','ep_ttm'});

        
        if bool
            ep_ttm = factor_append(ep_ttm,append);
        else
            ep_ttm = append;
        end
            
        data = ep_ttm.data; %#ok<NASGU>
        code_map = ep_ttm.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end

end



