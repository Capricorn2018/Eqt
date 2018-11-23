% factor mimicking portfolio
% 即用回归方程中 f = H' * r 来确定的H, 每一行是一个因子对应的fmp
% X: 应该是经过所有处理之后的因子矩阵, 包括style的正规化、style间去共线、和行业因子约束的去共线处理
% weight_array: 对应每只股票的weight, 通常是每只股票的总市值或流通市值

function fm = factor_mimicking(style, risk_factors, weight_array)

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

    % W即回归方程中的weight, 通常用sqrt(markcap)
    W = diag(weight);
    
    % 最后结果 H = (X' * W * X)^(-1) * X' * W
    H = (X' * W * X) \ (X'*W);
    
    fm = nan(length(z),1);
    fm(notnan_all) = H(2,:);

end

