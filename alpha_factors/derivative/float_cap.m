function [] = float_cap( a,p)
% 计算总市值和A股流通市值

    tgt_file = [a.input_data_path,'/LR_float_cap.mat'];
    if exist(tgt_file,'file')==2
        float_cap = load(tgt_file);
        dt = float_cap.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        shr = load([a.input_data_path,'/LR_float_a_shr.mat']);
        p = load([a.input_data_path,'/LR_s_dq_close.mat']);
        
        shr.data = shr.data(shr.data.DATEN>dt_max,:);
        p.data = p.data(p.data.DATEN>dt_max,:);
        
        append = factor_join(shr,p,{'float_a_shr'},{'s_dq_close'});
        
        append.data.float_cap = (append.data.float_a_shr*10000) ...
                                .* append.data.s_dq_close;
                                                        
        append.data = append.data(:,{'DATEN','stk_num','float_cap'});
        
        if bool
            float_cap = factor_append(float_cap,append);
        else
            float_cap = append;
        end
            
        data = float_cap.data; %#ok<NASGU>
        code_map = float_cap.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end

end

