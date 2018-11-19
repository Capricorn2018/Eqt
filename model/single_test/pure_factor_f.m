function w = pure_factor_f(X, markcap)

    notnan_X = any(~isnan(X),2);
    notnan_markcap = ~isnan(markcap);
    
    notnan_all = notnan_X & notnan_markcap;
    
    markcap = markcap(notnan_all);
    X = X(notnan_all,:);

    W = diag(sqrt(markcap/nansum(markcap)));
    
    w = X' * W / (X' * W * X);

end

