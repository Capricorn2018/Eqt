function [ output_args ] = portfolio_const( lambda, ... % �������ͷ���
                                            c, % �����ʳͷ���
                                            w_bench, ... % ����ָ��Ȩ��
                                            w_0, ... % ��һ�ڳֲ�Ȩ��
                                            alpha_f, alpha_w, ... % alpha���ӱ�¶��alpha���Ӽ�Ȩ����
                                            risk_cov, risk_exp, res_vol, ... % ����ģ�͵�������
                                            risk_min,risk_max, ... % �������ӱ�¶�Ͻ�
                                            w_max, w_min, ...  % ��ֻ��ƱȨ������
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
    risk_idx = risk_max<Inf | risk_min>-Inf;
    risk_mtx = risk_exp(:,risk_idx); % constraints�еı�¶����
    risk_min = risk_min(risk_idx); % ��Ӧ��constraint��������
    risk_max = risk_max(risk_idx);
    

    % ���ﻹҪ����ȥNaN        
    n = length(res_vol); %#ok<NASGU>
    cvx_begin
        variable x(n)
        maximize(alpha_w' * alpha_f' * x ...
                    - lambda * quad_form(risk_exp' * x, risk_cov) - lambda * sum(res_vol .* x .* x) ...
                    - c * norm(w-w_0,1))
        subject to
            w == w_bench + x; %#ok<EQEFF>
        	w >= 0; %#ok<VUNUS>
            quad_form(risk_exp' * x, risk_cov) <= risk_bound*risk_bound; %#ok<VUNUS>
            % sum(w) == 1; %#ok<EQEFF>
            risk_min <= risk_mtx' * x <= risk_max; %#ok<VUNUS>
            w_min <= w <= w_max; %#ok<CHAIN,VUNUS>
    cvx_end

    w(not_nan) = x;


end

