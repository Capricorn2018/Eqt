% 风格(行业)中性调整
% style是待评估的alpha因子
% risk_factors是用于回归的矩阵, 其中每一列是一个做过去极值和归一化的风险因子, 或行业因子

% 按照东方证券朱剑涛的做法, 财务因子要做行业中性和风格中性, 技术因子只做风格中性, 待讨论

function res_factor = risk_adj_factor(style, risk_factors, weight_array)

    % 这里默认用weight_array的1/2次方作为weight矩阵的对角线
    weight_matrix = diag(sqrt(weight_array));
    
    % 在risk_factors中加入一列截距项
    X = [ones(size(risk_factors,1),1),risk_factors];

    % 纯线性回归, 这个matlab函数会自动去掉有空值的列
    % 这里不知道是不是要考虑做稳健回归
    mdl = fitlm(weight_matrix * X, weight_matrix * style);
        
    % 在residual上乘以weight_matrix的逆就是最终结果
    weight_matrix_inv = diag(1/sqrt(weight_array));
    res_factor = mdl.Residuals * weight_matrix_inv;

end