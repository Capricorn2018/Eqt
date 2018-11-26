% factor mimicking portfolio
% a: 用于传入读数据的路径
% style_table: 一个table, 第一列是datenum, 之后是每日对应因子截面数据
% risk_factor_names: 需要做中性化的风险因子名称, 例如'beta'

%%
% 若只想在一个指数成分范围内做分析, 则只需要把style_table中的其他票都设为NaN即可
%% 问题
% 还有个问题, 这里style是单独做的正态化, risk factors却是做risk之前在全市场范围做的正态化
%%
function weight_table = factor_mimicking(a,style_table,risk_factor_names)

    % 日期序列
    dt = style_table(:,1);
    dt = table2array(dt);
    
    % 初始化weight
    weight = nan(height(style_table),width(style_table)-1);    
    weight_table = [style_table(:,1),array2table(weight)];
    weight_table.Properties.VariableNames = style_table.Properties.VariableNames;
    
    % 按日循环
    for i=1:length(dt)
        
       date = datestr(dt(i),'yyyy-mm-dd'); 
       % a.regression是读取回归所用矩阵的文件夹地址
       % 暂时看是D:\Capricorn\model\risk\regression\
       filename = [a.regression,'\Index0_',date,'.mat'];
       
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
       style = style_table(i,stk_codes);
       style = table2array(style);
       style = mad_zscore(style); % 正态化
       
       % 计算factor mimicking portfolio
       weight_table(i,stk_codes) = array2table(factor_mmck(style,risk_factors)');
        
    end
    
end


% 即用回归方程中 f = H' * r 来确定的H, 每一行是一个因子对应的fmp
% style: 需要评估的因子, 这里只要 原 始 因 子 即可
% risk_factors：这个可以用risk model里面现成的回归矩阵
% weight_array: 对应每只股票的weight, 通常是每只股票的总市值或流通市值
function fm = factor_mmck(style, risk_factors, weight_array)

    if(nargin==2)
       weight_array = ones(length(style),1); 
    end
    
    z = mad_zscore(style);
    X = [ones(length(z),1),z,risk_factors];

    % 去NaN的行
    notnan_X = ~any(isnan(X),2);
    % 去markcap的NaN
    notnan_weight = ~isnan(weight_array);    
    % 所有的NaN
    notnan_all = notnan_X & notnan_weight;
    
    weight = weight_array(notnan_all);
    X = X(notnan_all,:);

    % W即回归方程中的weight, 通常用markcap
    W = diag(weight);
    
    % 最后结果 H = (X' * W * X)^(-1) * X' * W
    H = (X' * W * X) \ (X'*W);
    
    fm = nan(length(z),1);
    % 取第2列即style对应的factor mimicking portfolio
    fm(notnan_all) = H(2,:);

end

