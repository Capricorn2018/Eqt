function res_factor = risk_adj_factor(style, risk_factors, weight_array)

    % 这里默认用weight_array的1/2次方作为weight矩阵的对角线
    weight_matrix = diag(sqrt(weight_array));
    
    X = [ones(size(risk_factors,1),1),risk_factors];

    mdl = fitlm(weight_matrix * X, weight_matrix * style);
    
    weight_matrix_inv = diag(1/sqrt(weight_array));
    res_factor = mdl.Residuals * weight_matrix_inv;

end