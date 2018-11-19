function w = pure_factor_opt(style, risk_factors, sectors, markcap, stk_cov)

    cvx_solver Mosek;
    
    w = zeros(length(style),1);
    
    [sec_factors, sec_weight] = sec_group(sectors,markcap);
    
    notnan_risk_factors = ~any(isnan(risk_factors),2);
    notnan_styles = ~any(isnan(styles),2);
    notnan_sectors = ~any(isnan(sectors),2);
    notnan_markcap = ~any(isnan(markcap),2);
    
    notnan_all = notnan_risk_factors & notnan_styles & notnan_sectors & notnan_markcap;
    style = style(notnan_all);
    stk_cov = stk_cov(notnan_all,notnan_all);
    risk_factors = risk_factors(notnan_all,:);
        
    % 这里还要考虑去NaN        
    n = length(style);
    cvx_begin
        variable x(n)
        minimize(quad_form(x,stk_cov))
        subject to
        	x >= 0; %#ok<VUNUS>
            risk_factors * x == 0; %#ok<EQEFF>
            sec_factors * x - sec_weight == 0; %#ok<EQEFF>
            style * x == 1; %#ok<EQEFF>
    cvx_end
    
    w(notnan_all) = x.Value;
    
end


function [sec_factors, sec_weight] = sec_group(sectors, markcap)

    tbl = [ array2table(sectors), array2table(markcap) ];
    sec_cap = grpstats(tbl,'sectors','nansum');
    sec_levels = sec_cap.sectors;
    sec_cap = sec_cap.nansum_markcap;
    
    sec_weight = sec_cap ./ nansum(sec_cap);
    
    N_sec = length(sec_levels);
    N_stk = length(sectors);
    sec_factors = zeros(N_stk,N_sec);
    
    for i = 1:N_sec
        sec_factors(sectors==sec_levels(i),i) = 1;
    end

end

