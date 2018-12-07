function x = optimizer(factor_cov, exposure, spk, exp_bound, active_bound)
%OPTIMIZER �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

    bound_idx = exp_bound<Inf;
    bound_mtx = exposure(:,bound_idx);
    bound = exp_bound(bond_idx);

    % ���ﻹҪ����ȥNaN        
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

