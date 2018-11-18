% 最简单的单因子测试, 用单因子分组分别计算历史收益曲线
% rtn_table是每只股票历史每日复权后收益table, 第一列是对应的日期int
% a: 存储各种路径
% tgt_tag: 因子名称
% tgt_file: 读取因子数据的文件名称
% rebalance_dates: 一个array, 里面存着需要做调仓的日期double
% rtn_table: 一个table, 第一列DATEN是每一个交易日double, 后面的列是每个股票的每日复权收益

function [nav_grp,weight_grp] = sector_neutral_test(a,tgt_tag,tgt_file,rebalance_dates,rtn_table,sectors_table,freecap_table)
    
    %%%%% 分组个数 %%%%%%%
    N_grp = 10;

    T = height(rtn_table);
    N = width(rtn_table)-1;
   
    % 调仓日个数
    N_reb = size(rebalance_dates,1);
    %rebalance_dates = table2array(rtn_table(rebalance_idx,1));
    
    % 读取对应的因子数据
    style = h5read([a.output_data_path,'\',tgt_file],['/',tgt_tag]);
    %sectors = table2array(sectors_table(:,2:end));
        
    % w用来存储
    w = zeros(N_grp,N_reb,N);
    
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
        ss = table2array(sectors_table(j,2:end));
        freecap = table2array(freecap_table(j,2:end));
        idx = 1:length(cs);
        
        cs = cs';
        ss = ss';
        cap = freecap';
                
        func1 = @(x) sector_group(x,N_grp);
        func2 = @(x) x;
        
        tbl_1 = [array2table(ss), array2table(cs)];
        sector_grp_weight = grpstats(tbl_1,'ss',func1);
        sector_grp_weight = sector_grp_weight(:,3);
        
        tbl_2 = [array2table(ss), array2table(idx)];
        grp_idx = grpstats(tbl_2,'ss',func2);
        grp_idx = grp_idx(:,3);
        
        tbl_3 = [array2table(ss), array2table(cap)];
        sector_cap = grpstats(tbl_3,'ss','nansum');
        sector_cap = sector_cap(:,3);
        
        % 当日因子非空的股票个数
        n_stk = length(cs(~isnan(cs)));
        
        % 弱当天因子值全为空值则默认空仓
        if(n_stk==0)
            continue;
        end
        
        w(:,i,:) = sector2actual(sector_grp_weight, grp_idx, sector_cap,N); 
        

    end
    
    % 初始化结果, weight_grp为一个struct, 把每个组的结果加进去
    simulated_nav_grp = ones(T,N_grp);
    weight_grp = struct;
    
    % 按组循环, 模拟净值
    group_names = cell(1,N_grp);
    for grp=1:N_grp
        % 第grp组的权重table
        weights_table = [array2table(rebalance_dates),array2table(squeeze(w(grp,:,:)))];
        weights_table.Properties.VariableNames = rtn_table.Properties.VariableNames;
        % 第grp组的交易成本table
        cost_table =[array2table(rebalance_dates),array2table(zeros(N_reb,N))];
        cost_table.Properties.VariableNames = rtn_table.Properties.VariableNames;

        % 模拟nav和生成weight
        [simulated_nav,weight] = simulator(rtn_table,weights_table,cost_table); %#ok<ASGLU>
        
        % 用eval给weight_grp这个struct加一个成分, 名称为 'group1', 'group2',...
        group_names(1,grp) = {['group',num2str(grp)]};
        eval(['weight_grp.group',num2str(grp),'= table2array(weight);']);
        % 把每个组的nav回测结果存入矩阵
        simulated_nav_grp(:,grp) = table2array(simulated_nav(:,2));
        
    end
    
    % 调整结果, 加入一列日期double
    nav_grp = [rtn_table(:,1),array2table(simulated_nav_grp)];
    nav_grp.Properties.VariableNames = ['DATEN' group_names];
    
end

% 从sector内权重到实际组内权重
function weight = sector2actual(sector_grp_weight, grp_idx, sector_cap,N_stks)

    sector_cap_array = table2array(sector_cap);
    sector_pct = sector_cap_array ./ nansum(sector_cap_array);
    %sector_pct = array2table(sector_pct, 'RowNames', sector_cap.Properties.RowNames);
    
    N_sectors = height(sector_cap);
    N_grp = height(sector_grp_weight(1,1));
    
    weight = zeros(N_grp, N_stks);
    
    for i = 1:N_sectors
    
        w = table2array(sector_grp_weight(i,1)) ./ sector_pct(i,1);        
        idx = table2array(grp_idx(i,1));
        weight(:,idx) = w;
        
    end
    

end 


function sector_grp_weight = sector_group(x,N_grp)

    q = [-Inf,quantile(x,N_grp-1)]';
    
    sector_grp_weight = zeros(length(x),N_grp);
    
    for grp=1:N_grp
        
        w = zeros(length(x),1);
       
        left_interval = q(grp);
        right_interval = q(grp+1);
        
        k_left = left_point(x,left_interval);
        x_left = x(k_left(1)); % 防止多个数重合的情况
        k_right = right_point(x,right_interval);
        x_right = x(k_right(1));
        
        %k_in = find(x <= right_interval & x > left_interval);
        
        if(isempty(kin))
            w(k_right) = 1;
            w = w ./ sum(w);
            
            sector_grp_weight(:,grp) = w;
            continue;
        end
        
        k_left_next = find_next(x,x_left);
        k_right_last = find_last(x,x_right);
        
        x_left_next = x(k_left_next(1));
        x_right_last = x(k_right_last(1));
        
        w(x <= right_interval & x > left_interval) = 1;
        w(k_left_next) = (x_left_next-left_interval)/(x_left_next-x_left);
        w(k_right) = (right_interval-x_right_last)/(x_right-x_right_last);
        
        w = w ./ sum(w);
        
        sector_grp_weight(:,grp) = w;
        
    end

end

function k = left_point(x,left_interval)

    y=x;
    
    y(x>left_interval) = -Inf;
    
    [~,k] = max(y);

end

function k = right_point(x,right_interval)

    y=x;
    
    y(x<=right_interval) = Inf;
    
    [~,k] = min(y);

end

function k = find_next(x,point)

    y = x;
    
    y(x<=point) = Inf;
    
    [~,k] = min(y);

end

function k = find_last(x,point)

    y = x;
    
    y(x>=point) = -Inf;
    
    [~,k] = max(y);

end
