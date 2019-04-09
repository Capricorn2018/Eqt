function [] = gross_margin(a, p)
% grossmargin_ttm 计算滚动12个月口径的 毛利率
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/gross_margin.h5'];
%     tgt_tag = 'gross_margin'; 
%     [S,gross_margin] =  check_exist(tgt_file,'/gross_margin',p,T,N);
% 
% 
%     if S>0
%        rev_file = [a.input_data_path,'/TTM_oper_rev.h5'];
%        cost_file = [a.input_data_path,'/TTM_less_oper_cost.h5'];
% 
%        rev = h5read(rev_file,'/oper_rev');
%        rev_stk = h5read(rev_file,'/stk_code');
%        rev_dt = datenum_h5(h5read(rev_file,'/date'));
%        cost = h5read(cost_file,'/less_oper_cost');
%        cost_stk = h5read(cost_file,'/stk_code');
%        cost_dt = datenum_h5(h5read(cost_file,'/date'));
%        
%        [~,p_i,rev_i,cost_i] = intersect3(p.stk_codes,rev_stk,cost_stk);
%        [~,p_t,rev_t,cost_t] = intersect3(p.all_trading_dates(S:T),rev_dt,cost_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        gross_margin(p_t,p_i) = 1 - cost(cost_t,cost_i)./rev(rev_t,rev_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/gross_margin.mat'];
    if exist(tgt_file,'file')==2
        gross_margin = load(tgt_file);
        dt = gross_margin.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        rev = load([a.input_data_path,'/TTM_oper_rev.mat']);
        cost = load([a.input_data_path,'/TTM_less_oper_cost.mat']);
        
        rev.data = rev.data(rev.data.DATEN>dt_max,:);
        cost.data = cost.data(cost.data.DATEN>dt_max,:);
        
        append = factor_join(rev,cost,{'oper_rev'},{'less_oper_cost'});
        
        append.data.gross_margin = 1 - append.data.less_oper_cost ...
                                                ./ append.data.oper_rev;
                            
        append.data = append.data(:,{'DATEN','stk_num','gross_margin'});

        
        if bool
            gross_margin = factor_append(gross_margin,append);
        else
            gross_margin = append;
        end
            
        data = gross_margin.data; %#ok<NASGU>
        code_map = gross_margin.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end

end

