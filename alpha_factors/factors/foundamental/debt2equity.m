function [] = debt2equity(a, p)
% debt2equity 计算最新季报（年报）口径的 debt/equity
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/debt2equity.h5'];
%     tgt_tag = 'debt2equity'; 
%     [S,debt2equity] =  check_exist(tgt_file,'/debt2equity',p,T,N);
% 
%     if S>0
%         
%        eqy_file = [a.input_data_path,'/LR_tot_shrhldr_eqy_excl_min_int.h5'];
%        debt_file = [a.input_data_path,'/LR_tot_liab.h5'];
% 
%        eqy = h5read(eqy_file,'/tot_shrhldr_eqy_excl_min_int');
%        eqy_stk = h5read(eqy_file,'/stk_code');
%        eqy_dt = datenum_h5(h5read(eqy_file,'/date'));
%        debt = h5read(debt_file,'/tot_liab');
%        debt_stk = h5read(eqy_file,'/stk_code');
%        debt_dt = datenum_h5(h5read(eqy_file,'/date'));
%        
%        [~,p_i,eqy_i,debt_i] = intersect3(p.stk_codes,eqy_stk,debt_stk);
%        [~,p_t,eqy_t,debt_t] = intersect3(p.all_trading_dates(S:T),eqy_dt,debt_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        debt2equity(p_t,p_i) = debt(debt_t,debt_i)./eqy(eqy_t,eqy_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/debt2equity.mat'];
    if exist(tgt_file,'file')==2
        debt2equity = load(tgt_file);
        dt = debt2equity.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        eqy = load([a.input_data_path,'/LR_tot_shrhldr_eqy_excl_min_int.mat']);
        debt = load([a.input_data_path,'/LR_tot_liab.mat']);
        
        eqy.data = eqy.data(eqy.data.DATEN>dt_max,:);
        debt.data = debt.data(debt.data.DATEN>dt_max,:);
        
        append = factor_join(eqy,debt,{'tot_shrhldr_eqy_excl_min_int'},{'tot_liab'});
        
        append.data.debt2equity = append.data.tot_liab ...
                                                    ./ append.data.tot_shrhldr_eqy_excl_min_int;
                            
        append.data = append.data(:,{'DATEN','stk_num','debt2equity'});

        
        if bool
            debt2equity = factor_append(debt2equity,append);
        else
            debt2equity = append;
        end
            
        data = debt2equity.data; %#ok<NASGU>
        code_map = debt2equity.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end

end

