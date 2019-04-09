function [] = tot_cap( a,p)
% 计算总市值和A股流通市值

    tgt_file = [a.input_data_path,'/LR_tot_cap.mat'];
    if exist(tgt_file,'file')==2
        tot_cap = load(tgt_file);
        dt = tot_cap.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        shr = load([a.input_data_path,'/LR_tot_shr.mat']);
        p = load([a.input_data_path,'/LR_s_dq_close.mat']);
        
        shr.data = shr.data(shr.data.DATEN>dt_max,:);
        p.data = p.data(p.data.DATEN>dt_max,:);
        
        append = factor_join(shr,p,{'tot_shr'},{'s_dq_close'});
        
        append.data.tot_cap = (append.data.tot_shr*10000) ...
                                .* append.data.s_dq_close;
                                                        
        append.data = append.data(:,{'DATEN','stk_num','tot_cap'});
        
        if bool
            tot_cap = factor_append(tot_cap,append);
        else
            tot_cap = append;
        end
            
        data = tot_cap.data; %#ok<NASGU>
        code_map = tot_cap.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end
    
end

