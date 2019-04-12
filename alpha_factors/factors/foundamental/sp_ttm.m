function [] = sp_ttm(a, p)
% sp_ttm 计算滚动12个月口径的 营业收入/总市值
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/sp_ttm.h5'];
%     tgt_tag = 'sp_ttm'; 
%     [S,sp_ttm] =  check_exist(tgt_file,'/sp_ttm',p,T,N);
%     
%     if S>0
%        rev_file = [a.input_data_path,'/TTM_oper_rev.h5'];
%        cap_file = [a.input_data_path,'/tot_cap.h5'];
% 
%        rev = h5read(rev_file,'/oper_rev');
%        rev_stk = h5read(rev_file,'/stk_code');
%        rev_dt = datenum_h5(h5read(rev_file,'/date'));
%        total_capital = h5read(cap_file,'/tot_cap');
%        cap_stk = h5read(cap_file,'/stk_code');
%        cap_dt = datenum_h5(h5read(cap_file,'/date'));
%        
%        [~,p_i,rev_i,cap_i] = intersect3(p.stk_codes,rev_stk,cap_stk);
%        [~,p_t,rev_t,cap_t] = intersect3(p.all_trading_dates(S:T),rev_dt,cap_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        sp_ttm(p_t,p_i) = rev(rev_t,rev_i)./total_capital(cap_t,cap_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/sp_ttm.mat'];
    if exist(tgt_file,'file')==2
        sp_ttm = load(tgt_file);
        dt = sp_ttm.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        rev = load([a.input_data_path,'/oper_rev.mat']);
        cap = load([a.input_data_path,'/LR_tot_cap.mat']);
        
        rev.data = rev.data(rev.data.DATEN>dt_max,:);
        cap.data = cap.data(cap.data.DATEN>dt_max,:);
        
        append = factor_join(rev,cap,{'oper_rev'},{'tot_cap'});
        
        append.data.sp_ttm = append.data.oper_rev ...
                                            ./ append.data.tot_cap;
                            
        append.data = append.data(:,{'DATEN','stk_num','sp_ttm'});

        
        if bool
            sp_ttm = factor_append(sp_ttm,append);
        else
            sp_ttm = append;
        end
            
        data = sp_ttm.data; %#ok<NASGU>
        code_map = sp_ttm.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end

end



