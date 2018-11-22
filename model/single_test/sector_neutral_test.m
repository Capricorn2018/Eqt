% 最简单的单因子测试, 用单因子分组分别计算历史收益曲线
% rtn_table是每只股票历史每日复权后收益table, 第一列是对应的日期int
% N_grp: 分组的个数, 一般用5组即可
% rebalance_dates: 一个array, 里面存着需要做调仓的日期double
% rtn_table: 一个table, 第一列DATEN是每一个交易日double, 后面的列是每个股票的每日复权收益

% 2018-11-21: 需要考虑style是不是在停牌日已经设为NaN, 如果不是的话要改code

function [nav_grp,weight_grp,nav_bench] = sector_neutral_test(N_grp,rebalance_dates,rtn_table,style_table,sectors_table,markcap_table)
    
    T = height(rtn_table);
    N_stk = width(rtn_table)-1;
   
    % 调仓日个数
    N_reb = size(rebalance_dates,1);
    
    style = style_table(:,2:end);
    style = table2array(style);
    
    sectors = sectors_table(:,2:end);
    sectors = table2array(sectors);
    
    markcap = markcap_table(:,2:end);
    markcap = table2array(markcap);
        
    % w用来存储权重
    w = zeros(N_grp,N_reb,N_stk);
    bench_w = zeros(N_reb,N_stk);
    
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
        cs = squeeze(style(j,:));
        
        % 当日所有股票对应的行业
        sec = sectors(j,2:end);
        
        % 当日所有股票的自由流通市值
        cap = markcap(j,2:end);
        
        % 用当日股票的自由流通市值计算基准权重
        bench_w(i,~isnan(cap)) = cap(~isnan(cap)) ./ nansum(cap);
                
        % 转为列向量
        cs = cs';
        sec = sec';
        cap = cap';
        
        % 创建一个table, 用grpstats函数统计行业和行业总市值
        tbl = [array2table(sec),array2table(cap)];
        stats = grpstats(tbl,'sec','nansum');
        sector_names = stats.sec; % 取得行业列表        
        sector_weight = stats.nansum_cap ./ sum(stats.nansum_cap); % 用行业总市值占比计算该行业比例
        
        % 当日因子非空的股票个数
        n_stk = length(cs(~isnan(cs)));
        
        % 弱当天因子值全为空值则默认空仓
        if(n_stk==0)
            continue;
        end
        
        for k = 1:length(sector_names)
            
            % 所有该行业的股票
            is_in_sector = (sec==sector_names(k));
            
            % 调用下面的quantile_group函数, 计算出该行业内每个group的权重
            mtx = quantile_group(cs(is_in_sector),N_grp) .* sector_weight(k);
            
            % 把w相应该交易日、该行业的权重更新
            w(:,i,is_in_sector) = mtx';
            
        end
        
    end
    
    % 初始化结果, weight_grp为一个struct, 把每个组的结果加进去
    simulated_nav_grp = ones(T,N_grp);
    weight_grp = struct;
    
    % 第grp组的交易成本table
    cost_table =[array2table(rebalance_dates),array2table(zeros(N_reb,N_stk))];
    cost_table.Properties.VariableNames = rtn_table.Properties.VariableNames;
    
    % 按组循环, 模拟净值
    group_names = cell(1,N_grp);
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
    
    % 基准收益率
    bench_w_table = [array2table(rebalance_dates),array2table(bench_w)];
    bench_w_table.Properties.VariableNames = rtn_table.Properties.VariableNames;
    [nav_bench,~] = simulator(rtn_table,bench_w_table,cost_table);
    
    % 调整结果, 加入一列日期double
    nav_grp = [rtn_table(:,1),array2table(simulated_nav_grp)];
    nav_grp.Properties.VariableNames = ['DATEN' group_names];
    
end


function quantile_grp_weight = quantile_group(x,N_grp)

    % 计算分组的划分点
    q = [-Inf,quantile(x,N_grp-1),Inf]';
    
    % 初始化结果矩阵
    quantile_grp_weight = zeros(length(x),N_grp);
    
    % 按组循环
    for grp=1:N_grp
        
        % 组内权重初始化
        w = zeros(length(x),1);
       
        % quantile interval的左端点和右端点
        left_interval = q(grp);
        right_interval = q(grp+1);
        
        % 若该组对应的interval中没有点，则只有离右端点最近的那个（些）点有权重
        if(all(~(x <= right_interval & x > left_interval)))
            % 对于matlab的quantile函数来说空的interval不会没有右边的点
            
            % 右边最近的那些点的下标
            k_right = right_point(x,right_interval);
            
            % 这些点的权重平均分配
            w(k_right) = 1;
            w = w ./ sum(w);
            
            % 结果赋值
            quantile_grp_weight(:,grp) = w;
            
            % 结束这个iteration
            continue;
        end
        
        % 组内的点先都赋予一样的权重, 其中组内最小的那个（那些）点的权重可能在下面被修改
        w(x <= right_interval & x > left_interval) = 1;
        
        % 如果interval不是最左边那个, 则找到interval之外左边最近的那个（那些）点
        % 然后按照interval覆盖比例赋予权重, 对interval内最小的那个（那些点）赋予权重
        if(left_interval>-Inf)
            
            % 得到interval左边离它最近的那个点的下标
            k_left = left_point(x,left_interval);
            
            % 那些点的值
            x_left = x(k_left(1)); % 防止多个数重合的情况

            % interval之内最小的那个（那些）点
            k_left_next = find_next(x,x_left);
            % 那些点的值
            x_left_next = x(k_left_next(1));  
            
            % 按照left_interval（左端点）到x_left_next（interval内最小的点）的距离
            % 占x_left（左边离interval最近的点）到x_left_next（interval内最小的点）的距离的比例赋予权重
            w(k_left_next) = (x_left_next-left_interval)/(x_left_next-x_left);
        end
        
        if(right_interval<Inf)       
            
            % 得到interval右边离它最近的那个点的下标
            k_right = right_point(x,right_interval);
            % 那些点的值
            x_right = x(k_right(1)); % 防止多个数重合的情况
            
            % interval中最大的那个（那些）点的下标
            k_right_last = find_last(x,x_right);
            % 那些点的值
            x_right_last = x(k_right_last(1));
            
            % 按照x_right_last（interval内最大的点）到right_interval（interval右端点）的距离
            % 占x_right_last（interval内最大的点）到x_right（右边离interval最近的点）的距离的比例赋予权重
            w(k_right) = (right_interval-x_right_last)/(x_right-x_right_last);
        end
        
        % 归一化       
        w = w ./ sum(w);
        
        % 该组的权重结果赋值
        quantile_grp_weight(:,grp) = w;
        
    end

end

% 寻找区间左端以外离区间左端点最近的点
function k = left_point(x,left_interval)

    y=x;
    
    if(left_interval>-Inf)
        % 大于左端点的点赋值为-Inf, 便于max取下标
        y(x>left_interval) = -Inf;
        % 最近的那些点的值
        [mx,~] = max(y);
        % 那些点的下标
        k = find(x==mx);
    else
        % 若左端点是-Inf, 说明不存在
        k = NaN;
    end

end

% 寻找区间右端以外离区间右端点最近的点
function k = right_point(x,right_interval)

    y=x;
    
    if( right_interval < Inf)
        % 小于等于右端点的点赋值为Inf, 便于min取下标
        y(x<=right_interval) = Inf;
        % 最近的那些点的下标
        [mn,~] = min(y);
        % 那些点的下标
        k = find(x==mn);
    else
        % 若右端点是Inf, 说明不存在
        k = NaN;
    end

end

% 寻找x中大于point的最小点（可能不止一个）的下标
function k = find_next(x,point)

    y = x;
    
    % 把所有小于等于point的点赋值为Inf方便后续使用min
    y(x<=point) = Inf;
    
    % 求大于point所有点中的最小值
    [mn,~] = min(y);
    
    % 那些点的下标
    k = find(x==mn);

end


% 寻找x中小于point的最大点（可能不止一个）的下标
function k = find_last(x,point)

    y = x;
    
    % 把大于等于point的所有点赋值为-Inf方便后续使用max
    y(x>=point) = -Inf;
    
    % 求小于point所有点的最大值
    [mx,~] = max(y);

    % 那些点的下标
    k = find(x==mx);
end
