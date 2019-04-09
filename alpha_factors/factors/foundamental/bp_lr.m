function [] = bp_lr(a, p)
% bp_lr 计算最新季报（年报）口径的 BP

    tgt_file = [a.output_data_path,'/bp_lr.mat'];
    if exist(tgt_file,'file')==2
        bp_lr = load(tgt_file);
        dt = bp_lr.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        eqy = load([a.input_data_path,'/LR_tot_shrhldr_eqy_excl_min_int.mat']);
        cap = load([a.input_data_path,'/LR_tot_cap.mat']);
        
        eqy.data = eqy.data(eqy.data.DATEN>dt_max,:);
        cap.data = cap.data(cap.data.DATEN>dt_max,:);
        
        append = factor_join(eqy,cap,{'tot_shrhldr_eqy_excl_min_int'},{'tot_cap'});
        
        append.data.bp_lr = append.data.tot_shrhldr_eqy_excl_min_int ...
                                                ./ append.data.tot_cap;
                            
        append.data = append.data(:,{'DATEN','stk_num','bp_lr'});

        
        if bool
            bp_lr = factor_append(bp_lr,append);
        else
            bp_lr = append;
        end
            
        data = bp_lr.data; %#ok<NASGU>
        code_map = bp_lr.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end

end

