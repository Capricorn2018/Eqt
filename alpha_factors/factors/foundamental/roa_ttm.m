function [] = roa_ttm(a, p)
% roa_ttm 计算滚动12个月口径的 ROA
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/roa_ttm.h5'];
%     tgt_tag = 'roa_ttm'; 
%     [S,roa_ttm] =  check_exist(tgt_file,'/roa_ttm',p,T,N);
% 
% 
%     if S>0
%        profit_file = [a.input_data_path,'/TTM_net_profit_excl_min_int_inc.h5'];
%        asset_file = [a.input_data_path,'/LR_tot_assets.h5'];
% 
% 
%        profit = h5read(profit_file,'/net_profit_excl_min_int_inc');
%        profit_stk = h5read(profit_file,'/stk_code');
%        profit_dt = datenum_h5(h5read(profit_file,'/date'));
%        asset = h5read(asset_file,'/tot_assets');
%        asset_stk = h5read(asset_file,'/stk_code');
%        asset_dt = datenum_h5(h5read(asset_file,'/date'));
%        
%        [~,p_i,profit_i,asset_i] = intersect3(p.stk_codes,profit_stk,asset_stk);
%        [~,p_t,profit_t,asset_t] = intersect3(p.all_trading_dates(S:T),profit_dt,asset_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        roa_ttm(p_t,p_i) = profit(profit_t,profit_i)./asset(asset_t,asset_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/roa_ttm.mat'];
    if exist(tgt_file,'file')==2
        roa_ttm = load(tgt_file);
        dt = roa_ttm.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        profit = load([a.input_data_path,'/TTM_net_profit_excl_min_int_inc.mat']);
        asset = load([a.input_data_path,'/LR_tot_assets.mat']);
        
        profit.data = profit.data(profit.data.DATEN>dt_max,:);
        asset.data = asset.data(asset.data.DATEN>dt_max,:);
        
        append = factor_join(profit,asset,{'net_profit_excl_min_int_inc'},{'tot_assets'});
        
        append.data.roa_ttm = append.data.net_profit_excl_min_int_inc ...
                                                ./ append.data.tot_assets;
                            
        append.data = append.data(:,{'DATEN','stk_num','roa_ttm'});

        
        if bool
            roa_ttm = factor_append(roa_ttm,append);
        else
            roa_ttm = append;
        end
            
        data = roa_ttm.data; %#ok<NASGU>
        code_map = roa_ttm.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end

end

