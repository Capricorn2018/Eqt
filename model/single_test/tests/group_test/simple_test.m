% 最简单的单因子测试, 用单因子分组分别计算历史收益曲线
% rtn_table是每只股票历史每日复权后收益table, 第一列是对应的日期int
% N_grp: 分组的个数, 一般5组即可
% rebalance_dates: 一个array, 里面存着需要做调仓的日期double
% rtn_table: 一个table, 第一列DATEN是每一个交易日double, 后面的列是每个股票的每日复权收益

% 2018-11-21: 需要考虑style是不是在停牌日已经设为NaN, 如果不是的话要改code

function [nav_grp,weight_grp,nav_bench] = simple_test(N_grp,rebalance_dates,rtn_table,style_table,markcap_table)
    
    T = height(rtn_table);
    N = width(rtn_table)-1;
   
    % 调仓日个数
    N_reb = size(rebalance_dates,1);
    %rebalance_dates = table2array(rtn_table(rebalance_idx,1));
    
    % 读取对应的因子数据
    style = style_table(:,2:end);
    style = table2array(style);
    
    % 读取市值数据
    markcap = markcap_table(:,2:end);
    markcap = table2array(markcap);
        
    % w用来存储
    w = zeros(N_grp,N_reb,N);
    
    % 基准权重
    bench_w = zeros(N_reb,N);
    
    % 每个调仓日计算组内持仓目标
    for i=1:N_reb

        % 在rtn_table对应的所有交易日终寻找调仓日对应的下标j
        j = find(table2array(rtn_table(:,1))==rebalance_dates(i,1),1,'first');
        
        % 需要取前一天的因子截面, j=j-1
        if(j>1)
            j = j - 1;
        else
            continue;
        end
        
        % cross sectional style, 当日因子截面
        js = find(table2array(style_table(:,1))==rebalance_dates(i,1),1,'first');
        cs = squeeze(style(js,:));
        
        % 当日市值截面
        cap = squeeze(markcap(j,:));
        
        % 按市值加权的基准权重
        bench_w(i,~isnan(cap)) = cap(~isnan(cap)) ./ nansum(cap);

        % 当日因子非空的股票个数
        n_stk = length(cs(~isnan(cs)));
        
        % 弱当天因子值全为空值则默认空仓
        if(n_stk==0)
            continue;
        end
        
        % 计算分组的划分点
        quantile_grp = [-Inf,quantile(cs,N_grp-1),Inf];
        
        % 对每一个分组计算simulated_nav
        for grp=1:N_grp            
            
            % 判断哪些股票在第grp个分组内
            is_in_grp = cs>quantile_grp(grp) & cs<=quantile_grp(grp+1);
            
            % 分组内股票个数
            n_in_grp = length(cs(is_in_grp));
            
            % 若分组内没有股票则默认权重都为0
            if(n_in_grp==0)
                continue;
            end
            
            % 这里先假设组内等权！！！
            w(grp,i,is_in_grp) = 1./n_in_grp;
        end

    end
    
    % 初始化结果, weight_grp为一个struct, 把每个组的结果加进去
    simulated_nav_grp = ones(T,N_grp);
    weight_grp = struct;
    
    % 按组循环, 模拟净值
    group_names = cell(1,N_grp);
    
    % 第grp组的交易成本table
    cost_table =[array2table(rebalance_dates),array2table(zeros(N_reb,N))];
    cost_table.Properties.VariableNames = rtn_table.Properties.VariableNames;
    
    for grp=1:N_grp
        % 第grp组的权重table
        weights_table = [array2table(rebalance_dates),array2table(squeeze(w(grp,:,:)))];
        weights_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

        % 模拟nav和生成weight
        [simulated_nav,weight] = simulator(rtn_table,weights_table,cost_table); %#ok<ASGLU>
        
        % 用eval给weight_grp这个struct加一个成分, 名称为 'group1', 'group2',...
        group_names(1,grp) = {['group',num2str(grp)]};
        eval(['weight_grp.group',num2str(grp),'= table2array(weight);']);
        % 把每个组的nav回测结果存入矩阵
        simulated_nav_grp(:,grp) = table2array(simulated_nav(:,2));
        
    end
    
    % 基准权重table
    bench_w_table = [array2table(rebalance_dates),array2table(bench_w)];
    bench_w_table.Properties.VariableNames = rtn_table.Properties.VariableNames;
    % 模拟nav和生成weight
    [nav_bench,~] = simulator(rtn_table,bench_w_table,cost_table);
    
    % 调整结果, 加入一列日期double
    nav_grp = [rtn_table(:,1),array2table(simulated_nav_grp)];
    nav_grp.Properties.VariableNames = ['DATEN' group_names];
    
end