% factor mimicking portfolio
% 即用回归方程中 f = H' * r 来确定的H, 每一行是一个因子对应的fmp
% X: 应该是经过所有处理之后的因子矩阵, 包括style的正规化、style间去共线、和行业因子约束的去共线处理
% markcap: 每日市值

function H = factor_mimicking(X, markcap)

    % 去NaN
    notnan_X = any(~isnan(X),2);
    notnan_markcap = ~isnan(markcap);    
    notnan_all = notnan_X & notnan_markcap;
    
    markcap = markcap(notnan_all);
    X = X(notnan_all,:);

    % W即回归方程中的weight, 通常用sqrt(markcap)
    W = diag(sqrt(markcap/nansum(markcap)));
    
    % 最后结果 H = (X' * W * X)^(-1) * X' * W
    H = X' * W / (X' * W * X);

end

