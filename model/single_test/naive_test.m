% 最简单的单因子测试, 用单因子分组分别计算历史收益曲线
% rtn_table是每只股票历史每日复权后收益table, 第一列是对应的日期int

function [simulated_nav_table,weight_grp] = naive_test(a,tgt_tag,tgt_file,rebalance_dates,rtn_table)
    
    %%%%% 分组个数 %%%%%%%
    N_grp = 10;

    T = height(rtn_table);
    N = width(rtn_table)-1;
   
    % 调仓日个数
    N_reb = size(rebalance_dates,1);
    %rebalance_dates = table2array(rtn_table(rebalance_idx,1));
    
    style = h5read([a.output_data_path,'\',tgt_file],['/',tgt_tag]);
    
    w = zeros(N_grp,N_reb,N);
    
    % 每个调仓日计算组内持仓目标
    for i=1:N_reb

        j = find(table2array(rtn_table(:,1))==rebalance_dates(i,1),1,'first');

        %[~,idx] = sort(style(j,:),direction);
        
        % cross sectional style, 当日因子截面
        cs = squeeze(style(j,:));

        % 当日因子非空的股票个数
        n_stk = length(cs(~isnan(cs)));
        
        if(n_stk==0)
            continue;
        end
        
        quantile_grp = [-Inf,quantile(cs,N_grp-1),Inf];
        
        % 对每一个分组计算simulated_nav
        for grp=1:N_grp
            
            
            is_in_grp = cs>quantile_grp(grp) & cs<=quantile_grp(grp+1);
            n_in_grp = length(cs(is_in_grp));
            
            if(n_in_grp==0)
                continue;
            end
            
            w(grp,i,is_in_grp) = 1./n_in_grp;
        end

    end
        
    simulated_nav_grp = ones(T,N_grp);
    weight_grp = struct;
    for grp=1:N_grp
        
        weights_table = [array2table(rebalance_dates),array2table(squeeze(w(grp,:,:)))];
        weights_table.Properties.VariableNames = rtn_table.Properties.VariableNames;
        cost_table =[array2table(rebalance_dates),array2table(zeros(N_reb,N))];
        cost_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

        [simulated_nav,weight] = simulator(rtn_table,weights_table,cost_table);
        
        eval(['weight_grp.group',num2str(grp),'= table2array(weight);']);
        simulated_nav_grp(:,grp) = table2array(simulated_nav(:,2));
        
    end
        
    simulated_nav_table = [rtn_table(:,1),array2table(simulated_nav_grp)];
    
end