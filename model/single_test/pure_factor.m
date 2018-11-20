% 计算纯因子组合权重, 即对style的暴露是1, risk factor和行业暴露都为0的最小风险组合
% style: 正规化后的因子
% risk_factors: 正规化后的风险因子矩阵
% sectors: 记录每日股票所在行业的矩阵
% markcap: 每日市值数据
% stk_cov: 股票间协方差矩阵, 可以用factor cov和residual vol算出来

function w = pure_factor(style, risk_factors, sectors, markcap, stk_cov)
    
    % 初始化权重结果
    w = zeros(length(style),1);
    
    % 计算行业因子矩阵, 并统计每个行业总权重
    [sec_factors, sec_weight] = sec_group(sectors,markcap);
    
    % 取得所有有nan的行并去掉
    notnan_risk_factors = ~any(isnan(risk_factors),2);
    notnan_styles = ~any(isnan(styles),2);
    notnan_sectors = ~any(isnan(sectors),2);
    notnan_markcap = ~any(isnan(markcap),2);
    
    % 没有NaN出现的行
    notnan_all = notnan_risk_factors & notnan_styles & notnan_sectors & notnan_markcap;
    
    % 取得最后进入回归的行
    style = style(notnan_all);
    stk_cov = stk_cov(notnan_all,notnan_all);
    risk_factors = risk_factors(notnan_all,:);
        
    % 用mosek solver
    cvx_solver Mosek;
        
    % 这里还要考虑去NaN        
    n = length(style); %#ok<NASGU>
    cvx_begin
        variable x(n)
        minimize(quad_form(x,stk_cov))
        subject to
        	x >= 0; %#ok<VUNUS>
            risk_factors * x == 0; %#ok<EQEFF>
            sec_factors * x - sec_weight == 0; %#ok<EQEFF>
            style * x == 1; %#ok<EQEFF>
    cvx_end
    
    % 结果
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

