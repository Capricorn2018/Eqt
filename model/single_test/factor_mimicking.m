function weight_table = factor_mimicking(a,rebalance_dates,style_table,markcap_table,risk_factor_names)
    
    % factor mimicking portfolio
    % a: 用于传入读数据的路径
    % style_table: 一个table, 第一列是datenum, 之后是每日对应因子截面数据
    % risk_factor_names: 需要做中性化的风险因子名称, 例如'beta'

    %%
    % 若只想在一个指数成分范围内做分析, 则只需要把style_table中的其他票都设为NaN即可
    %% 问题
    % 还有个问题, 这里style是单独做的正态化, risk factors却是做risk之前在全市场范围做的正态化
    %%
    
    % 初始化weight
    weight = nan(rebalance_dates,width(style_table)-1);    
    weight_table = [array2table(rebalance_dates),array2table(weight)];
    weight_table.Properties.VariableNames = style_table.Properties.VariableNames;
    
    % 按日循环
    for i=1:length(dt)
        
       date = datestr(rebalance_dates(i),'yyyy-mm-dd'); 
       % a.regression是读取回归所用矩阵的文件夹地址
       % 暂时看是D:\Capricorn\model\risk\regression\
       filename = [a.single_test.regression,'\Index0_',date,'.mat'];
       
       % 判断文件是否存在, 不存在直接跳下一次循环
       if(exist(filename,'file')==2)
           load(filename);
       else
           continue;
       end
       
       % 从回归数据中读取相应的风险因子, 若当天无此因子则跳入下一次循环
       try
           risk_factors = table2array(pre_reg(:,risk_factor_names));  %#ok<NODEF>
       catch
           continue;
       end       
       
       % 若每行都有空值则跳入下一次循环
       if(all(any(isnan(risk_factors),2)))
           continue;
       end       
       
       % 从风险因子矩阵中读取当日股票代码
       stk_codes = pre_reg.Properties.RowNames;
       
       % 截取style中同样代码股票
       j = find(rebalance_dates(i),dt,'first');
       style = style_table(j,stk_codes);
       style = table2array(style)';
       cap = markcap_table(j,stk_codes);
       cap = table2array(cap)';
       
       % 计算factor mimicking portfolio
       weight_table(i,stk_codes) = array2table(factor_mmck(style,cap,risk_factors)');
        
    end
        
end


% 即用回归方程中 f = H' * r 来确定的H, 每一行是一个因子对应的fmp
% style: 需要评估的因子, 这里只要 原 始 因 子 即可
% risk_factors：这个可以用risk model里面现成的回归矩阵
% weight_array: 对应每只股票的weight, 通常是每只股票的总市值或流通市值
function fm = factor_mmck(style, cap, risk_factors)

    %if(nargin==2)
    %   weight_array = ones(length(style),1); 
    %end
    
    % 去NaN的行
    non_nan = (~isnan(style)) & (~any(isnan(risk_factors),2)) & (~isnan(cap));
    
    style = style(non_nan);
    cap = cap(non_nan);
    weight = sqrt(cap);
    
    z = mad_zscore(style,cap);
    % 因子收益回归中的矩阵, 如果加了所有行业因子则不需要加第一列1
    X = [ones(length(z),1),z,risk_factors];
    
    X = X(non_nan,:);

    % W即回归方程中的weight, 通常用markcap
    W = diag(weight);
    
    % 最后结果 H = (X' * W * X)^(-1) * X' * W
    H = (X' * W * X) \ (X'*W);
    
    fm = nan(length(style),1);
    % 取第2列即style对应的factor mimicking portfolio
    fm(non_nan) = H(2,:);

end

