function [] = asset_turnover(a, p)
% asset_turnover 计算最新季报（年报）口径的资产周转率

%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/asset_turnover.h5'];
%     tgt_tag = 'asset_turnover'; 
%     [S,asset_turnover] =  check_exist(tgt_file,'/asset_turnover',p,T,N);
%     
%     if S>0
%         
%        rev_file = [a.input_data_path,'/TTM_oper_rev.h5'];
%        asset_file = [a.input_data_path,'/MEAN_tot_assets.h5'];
% 
%        rev = h5read(rev_file,'/oper_rev');
%        rev_stk = h5read(rev_file,'/stk_code');
%        rev_dt = datenum_h5 (h5read(rev_file,'/date'));
%        asset = h5read(asset_file,'/tot_assets');
%        asset_stk = h5read(asset_file,'/stk_code');
%        asset_dt = datenum_h5 (h5read(asset_file,'/date'));
%        
%        [~,p_i,rev_i,asset_i] = intersect3(p.stk_codes,rev_stk,asset_stk);
%        [~,p_t,rev_t,asset_t] = intersect3(p.all_trading_dates(S:T),rev_dt,asset_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        asset_turnover(p_t,p_i) = rev(rev_t,rev_i)./asset(asset_t,asset_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end
    
    
    
    
    
    
    
    
    tgt_file = [a.output_data_path,'/asset_turnover.mat'];
    x = load(tgt_file);
    asset_turnover = x.asset_turnover;    
    dt = yyyy2datenum(asset_turnover.date);
    dt_max = max(dt);
    
    if dt_max<p.all_trading_dates(end)
        
        rev = load([a.input_data_path,'/TTM_oper_rev.mat']);
        asset = load([a.input_data_path,'/MEAN_tot_assets.mat']);
        
        rev_date = yyyy2datenum(rev.date);
        asset_date = yyyy2datenum(asset.date);
        
        append = join(rev(rev_date>dt_max,:),asset(asset_date>dt_max,:),'Keys',{'s_info_windcode','date'});
        
        append.asset_turnover = append.oper_rev/append.tot_assets;
        
        asset_turnover = [asset_turnover;append(:,asset_turnover.Properties.VariableNames)]; %#ok<NASGU>
        
        eval(['save(''',tgt_file,''',''asset_turnover'');]']);
        
    end

end

