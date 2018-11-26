% 这个函数用来统计单因子分组中long一组short一组的净值曲线状态
% rebalance_dates: 一列datenum, 传给函数每个调仓日期
% nav_grp: 一个table, 第一列是datenum, 后面每一列是一个分组的nav
% ls_rtn: long第一组short最后一组的每个区间收益
% ls_nav: long第一组short最后一组的净值曲线
% mean_rt: 调仓期区间的平均收益
% hit_ratio: 多空组合的区间胜率
% ls_ir: 策略的IR
% max_dd: 策略的最大回撤

function [ls_rtn,ls_nav,mean_ret,hit_ratio,ls_ir,max_dd] = grp_stats(rebalance_dates,nav_grp,nav_bench)

    % 把rebalance_dates变为cellstr方便后续用字符串索引
    rebalance_str = cellstr(num2str(rebalance_dates));
    
    % 第一组的nav和return
    nav1 = table2array(nav_grp(:,2));
    rtn1 = nav1(2:end) ./ nav1(1:end-1) - 1;
    
    % 最后一组的nav和return
    navN = table2array(nav_grp(:,width(nav_grp)));
    rtnN = navN(2:end) ./ navN(1:end-1) - 1;
    
    % ls的每日return
    daily_rtn = (1 - rtn1 + rtnN);
    
    % ls的每日nav
    ls = cumprod(daily_rtn);
    ls = [array2table(nav_grp.DATEN), array2table(ls)];
    ls.Properties.RowNames = cellstr(num2str(nav_grp.DATEN));
    ls.Properties.VariableNames = {'DATEN', 'nav'};
    
    % 用字符串索引取对应调仓日的nav
    ls_nav = ls(rebalance_str);
    
    % 调仓日之间ls组合的return
    ls_rtn = ls_nav(2:end) ./ ls_nav(1:end-1) - 1;
    
    % 平均的期间持有收益
    mean_ret = mean(ls_rtn);
    
    % 月(周、日)胜率
    hit_ratio = length(ls_rtn(ls_rtn>0))/length(ls_rtn);
    
    % ls组合的information ratio
    ls_ir = mean(daily_rtn)/std(daily_rtn)*sqrt(250);
    
    % 计算最大回撤
    [~, max_dd] = get_DD_table(ls.DATEN,ls.nav);
    max_dd = min(max_dd);
    
    stats_plot(rebalance_dates,nav_grp,nav_bench);

end


% 给分组收益画barplot
function stats_plot(rebalance_dates,nav_grp,nav_bench)

%     N_grp = size(nav_grp,2)-1;
%     
%     for grp = 1:N_grp
% 
%         eval(['nav_grp_',num2str(grp),'=nav_grp(:,',num2str(grp+1),');']);
%         cum_rtn = eval(['nav_grp_',num2str(grp)]);
%         cum_rtn = table2array(cum_rtn);
% 
%         plot(cum_rtn);
%         hold on;
%         
%     end
% 
%     hold off;
    
    % rebalance_date转为cellstr用于索引
    rebalance_str = cellstr(num2str(rebalance_dates));
    
    % 设置行名便于rebalance_str用于索引
    nav_grp.Properties.RowNames = cellstr(num2str(nav_grp.DATEN));
    nav_bench.Properties.RowNames = cellstr(num2str(nav_grp.DATEN));
    
    % 取得nav在对应调仓日的值
    reb_nav = table2array(nav_grp(rebalance_str,2:end));
    
    % 计算区间收益
    reb_rtn = reb_nav(2:end,:) ./ reb_nav(1:end-1,:) - 1;
    
    % benchmark的区间收益
    bench = table2array(nav_bench(rebalance_str,2:end));
    bench_rtn = bench(2:end,:) ./ bench(1:end-1,:) - 1;
    
    % 区间超额
    excess_rtn = reb_rtn - repmat(bench_rtn,1,size(reb_rtn,2));
    
    % 区间超额均值
    grp_mean = mean(excess_rtn,1);
    
    % barplot
    bar(grp_mean);
    
end

