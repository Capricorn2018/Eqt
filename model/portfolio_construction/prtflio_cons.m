function [ output_args ] = portfolio_const( lambda, ... % �������ͷ���
                                            w_bench, ... % ����ָ��Ȩ��
                                            w_0, ... % ��һ�ڳֲ�Ȩ��
                                            alpha_f, alpha_w, ... % alpha���ӱ�¶��alpha���Ӽ�Ȩ����
                                            risk_cov, risk_exp, res_vol, ... % ����ģ�͵�������
                                            risk_bound, ... % �������ӱ�¶�Ͻ�
                                            max_w, ...  % ��ֻ��ƱȨ������
                                            turn_bound, ... % ����������
                                            track_err) % �����������

    w = zeros(length(res_vol),1); % �����ʼ��
    
    % ȥ��nan
    not_nan = ~any(isnan(risk_exp),2) & ~isnan(res_vol) & ~any(isnan(alpha_f),2);
    risk_exp = risk_exp(not_nan,:);
    res_vol = res_vol(not_nan);
    alpha_f = alpha_f(not_nan,:);
    
    %%%%%
    alpha_f(isnan(alpha_f)) = 0;
    %%%%%
    
    max_w = max_w(not_nan);
        
    % ��ȡ��Ч�����ӱ�¶constraints, ��Щ���ӿ��ܲ�����
    bound_idx = risk_bound<Inf;
    bound_mtx = risk_exp(:,bound_idx); % constraints�еı�¶����
    bound = risk_bound(bound_idx); % ��Ӧ��constraint��������
    

    % ���ﻹҪ����ȥNaN        
    n = length(res_vol); %#ok<NASGU>
    cvx_begin
        variable x(n)
        maximize(alpha_f_rtn' * alpha_f' * x - lambda * quad_form(risk_exp' * x,factor_cov) - lambda * sum(res_vol .* x .* x))
        subject to
        	x >= 0; %#ok<VUNUS>
            sum(x) == 1; %#ok<EQEFF>
            -bound <= bound_mtx' * x <= bound; %#ok<VUNUS>
            -max_w <= x <= max_w; %#ok<VUNUS>
    cvx_end

    w(not_nan) = x;


end

