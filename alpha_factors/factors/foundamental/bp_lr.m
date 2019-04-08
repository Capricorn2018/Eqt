function [] = bp_lr(a, p)
% bp_lr 计算最新季报（年报）口径的 BP

%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/bp_lr.h5'];
%     tgt_tag = 'bp_lr'; 
%     [S,bp_lr] =  check_exist(tgt_file,'/bp_lr',p,T,N);
% 
%     if S>0
%         
%        eqy_file = [a.input_data_path,'/LR_tot_shrhldr_eqy_excl_min_int.h5']; 
%        cap_file = [a.input_data_path,'/tot_cap.h5'];
% 
%        eqy = h5read(eqy_file,'/tot_shrhldr_eqy_excl_min_int');
%        eqy_stk = h5read(eqy_file,'/stk_code');
%        eqy_dt = datenum_h5(h5read(eqy_file,'/date'));
%        total_capital = h5read(cap_file,'/tot_cap');       
%        cap_stk = h5read(cap_file,'/stk_code');
%        cap_dt = datenum_h5(h5read(cap_file,'/date'));
%        
%        [~,p_i,eqy_i,cap_i] = intersect3(p.stk_codes,eqy_stk,cap_stk);
%        [~,p_t,eqy_t,cap_t] = intersect3(p.all_trading_dates(S:T),eqy_dt,cap_dt);
%        idx = S:T;
%        p_t = idx(p_t);      
%        
%        bp_lr(p_t,p_i) = eqy(eqy_t,eqy_i)./total_capital(cap_t,cap_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end
    
    
    tgt_file = [a.output_data_path,'/bp_lr.mat'];
    if exist(tgt_file,'file')==2
        x = load(tgt_file);
        bp_lr = x.bp_lr;    
        dt = yyyy2datenum(bp_lr.date);
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        eqy = load([a.input_data_path,'/LR_tot_shrhldr_eqy_excl_min_int.mat']);
        shr = load([a.input_data_path,'/LR_tot_shr.mat']);
        p = load([a.input_data_path,'/LR_s_dq_adjclose.mat']);
        
        eqy.data = eqy.data(eqy.data.DATEN>dt_max,:);
        shr.data = shr.data(shr.data.DATEN>dt_max,:);
        p.data = p.data(p.data.DATEN>dt_max,:);
        
        x = factor_join(eqy,shr,{'tot_shrhldr_eqy_excl_min_int'},{'tot_shr'});
        append = factor_join(x,p,{'tot_shrhldr_eqy_excl_min_int','tot_shr'},{'s_dq_adjclose'});
        
        append.data.bp_lr = append.data.tot_shrhldr_eqy_excl_min_int ...
                                ./ append.data.tot_shr ...
                                ./ append.data.s_dq_adjclose;
                            
        append.data = append.data(:,{'DATEN','stk_num','bp_lr'});

        
        if bool
            bp_lr = factor_append(bp_lr,append); %#ok<NASGU>
        else
            bp_lr = append; %#ok<NASGU>
        end
            
        eval(['save(''',tgt_file,''',''bp_lr'');']);
        
    end

end

