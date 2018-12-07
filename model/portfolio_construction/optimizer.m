function x = optimizer(factor_cov, exposure, spk, exp_bound, active_bound)
%OPTIMIZER 此处显示有关此函数的摘要
%   此处显示详细说明

    bound_idx = exp_bound<Inf;
    bound_mtx = exposure(:,bound_idx);
    bound = exp_bound(bond_idx);

    % 这里还要考虑去NaN        
    n = size(exposure,1); %#ok<NASGU>
    cvx_begin
        variable x(n)
        minimize(quad_form(exposure' * x,factor_cov) + sum(spk .* x))
        subject to
        	%x >= 0; %#ok<VUNUS>
            sum(x) == 0; %#ok<EQEFF>
            -bound <= bound_mtx' * x <= bound; %#ok<VUNUS>
            -active_bound <= x <= active_bound; %#ok<VUNUS>
    cvx_end


end

