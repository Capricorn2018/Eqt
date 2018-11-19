function res_factor = risk_adj_factor(style, risk_factors)
    
    X = [ones(size(risk_factors,1),1),risk_factors];

    mdl = fitlm(X,style);
    
    res_factor = mdl.Residuals;

end