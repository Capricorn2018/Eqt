% 2018-11-21: 需要考虑style是不是在停牌日已经设为NaN, 如果不是的话要改code

function [ic, ic_ir] = style_ic(rebalance_dates, style_table, rtn_table)

    % rebalance_dates变cellstr方便后续使用字符串索引
    rebalance_str = cellstr(num2str(rebalance_dates));
    
    % 以日期数字的字符作为行名，便于索引
    style_table.Properties.RowNames = cellstr(num2str(rtn_table.DATEN));
    
    % 用字符串索引取得调仓日的style
    style = table2array(style_table(rebalance_str,2:end));
    
    % 从daily return转到daily nav, 其中NaN的日期按nav不变处理
    nav = rtn2nav(rtn_table);
    
    % 转table, 使用日期数字的字符串作为行名便于索引
    nav_table = array2table(nav,'RowNames',style_table.Properties.RowNames);
    
    % 取得调仓日的nav, 并用于计算期间收益
    nav_reb = nav_table(rebalance_str,:);
    nav_reb = table2array(nav_reb);
    rtn_reb = nav_reb(2:end,:)./nav_reb(1:end-1,:) - 1;
    
    % 初始化结果
    ic = zeros(size(rtn_reb,1)-1,1);
    
    for i = 1:length(ic)
        % 用spearman rho做ranked ic
        ic(i) = spearman_rho(style(i,:),rtn_reb(i,:));
    end
    
    % 计算ic/std(ic)用以衡量ic的稳定意义
    ic_ir = mean(ic)/std(ic);
    
end

% 从daily return的rtn_table计算出对应的股票每日nav
function nav = rtn2nav(rtn_table)

    % 去掉第一列日期并转array
    rtn = rtn_table(:,2:end);
    rtn = table2array(rtn);
    
    % 把NaN都设置成return=0
    rtn_delnan = rtn;
    rtn_delnan(isnan(rtn)) = 0;
    
    % 计算每只股票每日的对应nav, 以第一个rebalance_dates为1
    nav = cumprod(rtn_delnan+1,1);
    
    % rtn_table为NaN的日期也设为NaN, 以免kendall tau计算时过多采用停牌票
    nav(isnan(rtn)) = NaN;

end


% 计算kendall tau用于ranked ic, style即当日因子截面, r即下一区间的收益
function cor = spearman_rho(style, r)

    % 寻找style和r都不是空值的位置
    not_nan = (~isnan(style)) & (~isnan(r));
    
    % 去掉空值后的style和r
    style_num = style(not_nan);
    r_num = r(not_nan);

    % 计算Kendall tau
    cor = corr(style_num',r_num','type','Spearman');

end