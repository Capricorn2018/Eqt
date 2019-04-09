function [] = costs2sales(a, p)
% costs2sales 计算滚动12个月口径的 三费/营业收入
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/costs2sales.h5'];
%     tgt_tag = 'costs2sales'; 
%     [S,costs2sales] =  check_exist(tgt_file,'/costs2sales',p,T,N);
%     
%     if S>0
%        scost_file = [a.input_data_path,'/TTM_less_selling_dist_exp.h5']; % 销售费用
%        mcost_file = [a.input_data_path,'/TTM_less_gerl_admin_exp.h5']; % 管理费用
%        fcost_file = [a.input_data_path,'/TTM_less_fin_exp.h5']; % 财务费用
%        profit_file = [a.input_data_path,'/TTM_oper_profit.h5'];
% 
%        scost = h5read(scost_file,'/less_selling_dist_exp');
%        scost_stk = h5read(scost_file,'/stk_code');
%        scost_dt = datenum_h5(h5read(scost_file,'/date'));
%        mcost = h5read(mcost_file,'/less_gerl_admin_exp');
%        mcost_stk = h5read(mcost_file,'/stk_code');
%        mcost_dt = datenum_h5(h5read(mcost_file,'/date'));
%        fcost = h5read(fcost_file,'/less_fin_exp');
%        fcost_stk = h5read(fcost_file,'/stk_code');
%        fcost_dt = datenum_h5(h5read(fcost_file,'/date'));
%        profit = h5read(profit_file,'/oper_profit');
%        profit_stk = h5read(profit_file,'/stk_code');
%        profit_dt = datenum_h5(h5read(profit_file,'/date'));
%        
%        [~,p_i,scost_i,mcost_i,fcost_i,profit_i] = intersect5(p.stk_codes,scost_stk,mcost_stk,fcost_stk,profit_stk);
%        [~,p_t,scost_t,mcost_t,fcost_t,profit_t] = intersect5(p.all_trading_dates(S:T),scost_dt,mcost_dt,fcost_dt,profit_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        costs2sales(p_t,p_i) = (scost(scost_t,scost_i)+mcost(mcost_t,mcost_i)+fcost(fcost_t,fcost_i))./profit(profit_t,profit_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/costs2sales.mat'];
    if exist(tgt_file,'file')==2
        costs2sales = load(tgt_file);
        dt = costs2sales.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        scost = load([a.input_data_path,'/TTM_less_selling_dist_exp.mat']);
        mcost = load([a.input_data_path,'/TTM_less_gerl_admin_exp.mat']);
        fcost = load([a.input_data_path,'/TTM_less_fin_exp.mat']);
        profit = load([a.input_data_path,'/TTM_oper_profit.mat']);
        
        scost.data = scost.data(scost.data.DATEN>dt_max,:);
        mcost.data = mcost.data(mcost.data.DATEN>dt_max,:);
        fcost.data = fcost.data(fcost.data.DATEN>dt_max,:);
        profit.data = profit.data(profit.data.DATEN>dt_max,:);
        
        x = factor_join(scost,mcost,{'less_selling_dist_exp'},{'less_gerl_admin_exp'});
        y = factor_join(x,fcost,{'less_selling_dist_exp','less_gerl_admin_exp'},{'less_fin_exp'});        
        append = factor_join(y,profit,{'less_selling_dist_exp','less_gerl_admin_exp','less_fin_exp'},{'oper_profit'});
        
        append.data.costs2sales = (append.data.less_selling_dist_exp ...
                                                    + append.data.less_gerl_admin_exp ...
                                                    + append.data.less_fin_exp) ...
                                                        ./ append.data.oper_profit;
                            
        append.data = append.data(:,{'DATEN','stk_num','costs2sales'});

        
        if bool
            costs2sales = factor_append(costs2sales,append);
        else
            costs2sales = append;
        end
            
        data = costs2sales.data; %#ok<NASGU>
        code_map = costs2sales.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end

end



