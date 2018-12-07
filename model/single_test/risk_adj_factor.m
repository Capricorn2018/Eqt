% 风格(行业)中性调整
% style_table: 待评估的alpha因子table, 第一列是日期, 列名是SZ000001这种格式
% risk_factors_names: cell, 用于回归计算风险中性因子所使用的风险因子名称, 对应风险模型数据中的列名,
%                     比如'beta','bp','tcap'
%%
% 若只想在一个指数成分范围内做分析, 则只需要把style_table中的其他票都设为NaN即可

%% 问题
% 2018-11-21: 按照东方证券朱剑涛的做法, 财务因子要做行业中性和风格中性, 技术因子只做风格中性, 待讨论
% 还有个问题, 这里style是单独做的正态化, risk factors却是做risk之前在全市场范围做的正态化
%%
function adj_style_table = risk_adj_factor(a,rebalance_dates,style_table,markcap_table,risk_factor_names)

    % 初始化结果
    adj_style = nan(length(rebalance_dates),width(style_table)-1);    
    adj_style_table = [array2table(rebalance_dates),array2table(adj_style)];
    adj_style_table.Properties.VariableNames = style_table.Properties.VariableNames;
    
    % 按天循环回归
    for i=1:length(rebalance_dates)
       % 日期字符串生成读risk_factor的文件名
       date = datestr(rebalance_dates(i),'yyyy-mm-dd'); 
       filename = [a.single_test.style,'\Index0_',date,'.mat'];
       
       % 判断文件是否存在
       if(exist(filename,'file')==2)
           load(filename);
       else
           continue;
       end
       
       % try catch模块避免当日没有传入的风险因子
       try
           risk_factors = table2array(T_sector_style(:,risk_factor_names)); %#ok<NODEF>
       catch
           continue;
       end
              
       % 若risk_factor每一行都有空值则退出这一步循环
       if(all(any(isnan(risk_factors),2)))
           continue;
       end       
       
       % 从risk_factor中读取当日股票名
       stk_codes = T_sector_style.Properties.RowNames;
       
       % 从目标style中截取risk_factor中也存在的股票名
       j = find(ismember(style_table.DATEN,rebalance_dates(i)),1,'first');
       style = style_table(j,stk_codes);
       style = table2array(style)';
       cap = markcap_table(j,stk_codes);
       cap = table2array(cap)';
       %style = mad_zscore(style,cap);
       
       % 回归取残差即当日结果
       adj_style_table(i,stk_codes) = array2table(calc_residual(style,cap,risk_factors)');
        
    end
    
end

% 给一天的因子截面和当天的风险因子矩阵, 回归计算残差即risk adjusted factor
% weight一般用sqrt(cap), 这里先不考虑加权重默认为1
function res_factor = calc_residual(style, cap, risk_factors)

    %if(nargin==2)
    %   weight_array = ones(length(style),1); 
    %end
    
    res_factor = nan(length(style),1);

    non_nan = (~isnan(style)) & (~any(isnan(risk_factors),2)) & (~isnan(cap));
    style = style(non_nan);
    cap = cap(non_nan);
    weight = sqrt(cap);
    
    % 先用raw factor算zscore
    % 这里用的MAD, risk model里面是boxplot
    zscore = mad_zscore(style,cap);
    
    % 在risk_factors中加入一列截距项
    X = [ones(size(risk_factors,1),1),risk_factors];
   
    y = zscore .* weight;
    % 回归矩阵也每一行乘以sqrt(cap)
    x = repmat(weight,1,size(X,2)) .* X(non_nan,:);

    % 这里不知道是不是要考虑做稳健回归
    [~,~,res] = regress(y,x);
        
    % 在residual上乘以weight_matrix的逆就是最终结果
    res_factor(non_nan) = res ./ weight;

end