% 风格(行业)中性调整
% style是待评估的alpha因子
% risk_factors是用于回归的矩阵, 其中每一列是一个做过去极值和归一化的风险因子, 或行业因子

% 2018-11-21: 按照东方证券朱剑涛的做法, 财务因子要做行业中性和风格中性, 技术因子只做风格中性, 待讨论

function adj_style_table = risk_adj_factor(a,style_table)

    dt = style_table(:,1);
    dt = table2array(dt);
    
    %style_array = table2array(style_table(:,2:end));
    
    adj_style = nan(height(style_table),width(style_table)-1);
    
    adj_style_table = [style_table(:,1),array2table(adj_style)];
    adj_style_table.Properties.VariableNames = style_table.Properties.VariableNames;
    
    for i=1:length(dt)
        
       date = datestr(dt(i),'yyyy-mm-dd'); 
       filename = [a.style,'Index0_',date,'.mat'];
       if(exist(filename,'file')==2)
           load(filename);
       else
           continue;
       end
       
       risk_factors = table2array(T_sector_style);
       risk_factors = risk_factors(:,[1:36,37,47]);
       if(all(any(isnan(risk_factors),2)))
           continue;
       end       
       
       stk_codes = T_sector_style.Properties.RowNames;
       style = style_table(i,stk_codes);
       style = table2array(style);
       style = mad_zscore(style);
       
       adj_style_table(i,stk_codes) = array2table(calc_residual(style,risk_factors)');
        
    end
    
end


function res_factor = calc_residual(style, risk_factors, weight_array)

    if nargin==2
       weight_array = ones(length(style),1); 
    end

    % 先用raw factor算zscore
    % 这里用的MAD, risk model里面是boxplot
    zscore = mad_zscore(style);
    
    % 在risk_factors中加入一列截距项
    X = [ones(size(risk_factors,1),1),risk_factors];

    % 纯线性回归, 这个matlab函数会自动去掉有空值的列
    % 这里不知道是不是要考虑做稳健回归
    mdl = fitlm(repmat(weight_array,1,size(X,2)) .* X, weight_array .* zscore);
        
    % 在residual上乘以weight_matrix的逆就是最终结果
    res_factor = mdl.Residuals.Raw ./ weight_array;

end