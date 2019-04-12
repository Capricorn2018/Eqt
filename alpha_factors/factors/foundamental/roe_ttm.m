function [] = roe_ttm(a, p)
% roe_ttm 计算滚动12个月口径的 ROE
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/roe_ttm.h5'];
%     tgt_tag = 'roe_ttm'; 
%     [S,roe_ttm] =  check_exist(tgt_file,'/roe_ttm',p,T,N);
% 
% 
%     if S>0
%        profit_file = [a.input_data_path,'/TTM_net_profit_excl_min_int_inc.h5'];
%        eqy_file = [a.input_data_path,'/LR_tot_shrhldr_eqy_excl_min_int.h5'];
% 
% 
%        profit = h5read(profit_file,'/net_profit_excl_min_int_inc');
%        profit_stk = h5read(profit_file,'/stk_code');
%        profit_dt = datenum_h5(h5read(profit_file,'/date'));
%        eqy = h5read(eqy_file,'/tot_shrhldr_eqy_excl_min_int');
%        eqy_stk = h5read(eqy_file,'/stk_code');
%        eqy_dt = datenum_h5(h5read(eqy_file,'/date'));
%        
%        [~,p_i,profit_i,eqy_i] = intersect3(p.stk_codes,profit_stk,eqy_stk);
%        [~,p_t,profit_t,eqy_t] = intersect3(p.all_trading_dates(S:T),profit_dt,eqy_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        roe_ttm(p_t,p_i) = profit(profit_t,profit_i)./eqy(eqy_t,eqy_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/roe_ttm.mat'];
    if exist(tgt_file,'file')==2
        roe_ttm = load(tgt_file);
        dt = roe_ttm.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        profit = load([a.input_data_path,'/TTM_net_profit_excl_min_int_inc.mat']);
        eqy = load([a.input_data_path,'/LR_tot_shrhldr_eqy_excl_min_int.mat']);
        
        profit.data = profit.data(profit.data.DATEN>dt_max,:);
        eqy.data = eqy.data(eqy.data.DATEN>dt_max,:);
        
        append = factor_join(profit,eqy,{'net_profit_excl_min_int_inc'},{'tot_shrhldr_eqy_excl_min_int'});
        
        append.data.roe_ttm = append.data.net_profit_excl_min_int_inc ...
                                                ./ append.data.tot_shrhldr_eqy_excl_min_int;
                            
        append.data = append.data(:,{'DATEN','stk_num','roe_ttm'});

        
        if bool
            roe_ttm = factor_append(roe_ttm,append);
        else
            roe_ttm = append;
        end
            
        data = roe_ttm.data; %#ok<NASGU>
        code_map = roe_ttm.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end

end

