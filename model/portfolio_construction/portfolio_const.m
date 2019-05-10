function [ output_args ] = portfolio_const( lambda, ... % 跟踪误差惩罚项
                                            c, % 换手率惩罚项
                                            w_bench, ... % 跟踪指数权重
                                            w_0, ... % 上一期持仓权重
                                            alpha_f, alpha_w, ... % alpha因子暴露和alpha因子加权比例
                                            risk_cov, risk_exp, res_vol, ... % 风险模型的输出结果
                                            risk_min,risk_max, ... % 风险因子暴露上界
                                            w_max, w_min, ...  % 单只股票权重上限
                                            turn_bound, ... % 换手率上限
                                            track_err) % 跟踪误差上限

    w = zeros(length(res_vol),1); % 结果初始化
    
    % 去掉nan
    not_nan = ~any(isnan(risk_exp),2) & ~isnan(res_vol) & ~any(isnan(alpha_f),2);
    risk_exp = risk_exp(not_nan,:);
    res_vol = res_vol(not_nan);
    alpha_f = alpha_f(not_nan,:);
    
    %%%%%
    alpha_f(isnan(alpha_f)) = 0;
    %%%%%
    
    max_w = max_w(not_nan);
        
    % 获取有效的因子暴露constraints, 有些因子可能不限制
    risk_idx = risk_max<Inf | risk_min>-Inf;
    risk_mtx = risk_exp(:,risk_idx); % constraints中的暴露矩阵
    risk_min = risk_min(risk_idx); % 对应的constraint的上下限
    risk_max = risk_max(risk_idx);
    

    % 这里还要考虑去NaN        
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

