function [] = oper_margin(a, p)
% oper_margin 计算滚动12个月口径的 营业利润率
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/oper_margin.h5'];
%     tgt_tag = 'oper_margin'; 
%     [S,oper_margin] =  check_exist(tgt_file,'/oper_margin',p,T,N);
% 
% 
%     if S>0
%        rev_file = [a.input_data_path,'/TTM_oper_rev.h5'];
%        profit_file = [a.input_data_path,'/TTM_oper_profit.h5'];
% 
% 
%        rev = h5read(rev_file,'/oper_rev');
%        rev_stk = h5read(rev_file,'/stk_code');
%        rev_dt = datenum_h5(h5read(rev_file,'/date'));
%        profit = h5read(profit_file,'/oper_profit');
%        profit_stk = h5read(profit_file,'/stk_code');
%        profit_dt = datenum_h5(h5read(profit_file,'/date'));
%        
%        [~,p_i,rev_i,profit_i] = intersect3(p.stk_codes,rev_stk,profit_stk);
%        [~,p_t,rev_t,profit_t] = intersect3(p.all_trading_dates(S:T),rev_dt,profit_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        oper_margin(p_t,p_i) = profit(profit_t,profit_i)./rev(rev_t,rev_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/oper_margin.mat'];
    if exist(tgt_file,'file')==2
        oper_margin = load(tgt_file);
        dt = oper_margin.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        rev = load([a.input_data_path,'/TTM_oper_rev.mat']);
        profit = load([a.input_data_path,'/TTM_oper_profit.mat']);
        
        rev.data = rev.data(rev.data.DATEN>dt_max,:);
        profit.data = profit.data(profit.data.DATEN>dt_max,:);
        
        append = factor_join(rev,profit,{'oper_rev'},{'oper_profit'});
        
        append.data.oper_margin = append.data.oper_profit ...
                                                ./ append.data.oper_rev;
                            
        append.data = append.data(:,{'DATEN','stk_num','oper_margin'});

        
        if bool
            oper_margin = factor_append(oper_margin,append);
        else
            oper_margin = append;
        end
            
        data = oper_margin.data; %#ok<NASGU>
        code_map = oper_margin.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end
    
end

