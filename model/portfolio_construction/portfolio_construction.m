% 计算纯因子组合权重, 即对style的暴露是1, risk factor和行业暴露都为0的最小风险组合
%%
% 若只想在一个指数成分范围内做分析, 则只需要把style_table中的其他票都设为NaN即可
%% 问题
% 还有个问题, 这里style是单独做的正态化, risk factors却是做risk之前在全市场范围做的正态化
%%
function weight_table = portfolio_construction(a,p,rebalance_dates,risk_factor_names)

    dt = p.optimization.trading_dates;

    % 初始化weight
    weight = nan(length(rebalance_dates),length(p.optimization.stk_codes));    
    weight_table = [array2table(rebalance_dates),array2table(weight)];
    weight_table.Properties.VariableNames = ['DATEN',p.optimization.stk_codes];
    
    % 按日循环
    for i=1:length(rebalance_dates)
        
       % 日期字符串
       date = datestr(rebalance_dates(i),'yyyy-mm-dd'); 
       % a.regression是读取回归所用矩阵的文件夹地址
       % 暂时看是D:\Capricorn\model\risk\regression\
       filename = [a.single_test.regression,'\Index0_',date,'.mat'];
       
       % 判断文件是否存在
       if(exist(filename,'file')==2)
           load(filename);
       else
           continue;
       end
       
       % try catch避免当日对应的风险因子不存在
       try
           risk_factors = table2array(pre_reg(:,risk_factor_names));  %#ok<NODEF>
           factor_rtn = table2array(factor_rtn(1,risk_factor_names));
       catch
           continue;
       end
       
       % 东方金工风险因子数据文件名, 是用py扒下来的
       % cov存在D;\Capricorn\model\dfquant_risk\cov\中
       % risk factors存在D:\Capricorn\model\dfquant_risk\factors\中
       % spec存在D:\Capricorn\model\dfquant_risk\spec中
       % 日期字符串换成yyyymmdd格式
       date = datestr(rebalance_dates(i),'yyyymmdd'); 
       cov_filename = [a.single_test.dfquant_risk,'\cov\cov_',date,'.csv'];
       factor_filename = [a.single_test.dfquant_risk,'\factors\risk_factors_',date,'.csv'];
       spec_filename = [a.single_test.dfquant_risk,'\spec\spec_',date,'.csv'];
       
       if(exist(cov_filename,'file')==2 && exist(factor_filename,'file')==2 && exist(spec_filename,'file')==2)
           cov = readtable(cov_filename);
           spec = readtable(spec_filename);
           factors = readtable(factor_filename);
           
           % 把东方金工数据中的行名称从数字转到SH600018这种格式
           stk_num = factors(2:end,1);
           stk_num = table2array(stk_num);
           stk_codes = df_stk_codes(stk_num);
           
           % 东方金工数据
           cov = table2array(cov(2:end,2:end));
           spec = table2array(spec(:,2));
           factors = table2array(factors(2:end,2:end));
           
           tbl_factors = array2table(factors,'RowNames',stk_codes);
           tbl_spec = array2table(spec,'RowNames',stk_codes);
           
           
       else
           continue;
       end
       
       
       if(all(any(isnan(risk_factors),2)))
           continue;
       end       
       
       % 当日回归矩阵中的股票代码
       stk_codes = pre_reg.Properties.RowNames;
       
       %......
       factors = tbl_factors(stk_codes,:);
       factors = table2array(factors);
       spec = tbl_spec(stk_codes,1);
       spec = table2array(spec);
       
       % 优化求解
       %weight_table(i,stk_codes) = array2table(minvol_opt(style,cap,risk_factors,stk_cov)');
       exp_bound = ones(size(cov,1),1) * 0.1;
       active_bound = ones(size(factors,1),1) * 0.02;
       weight_table(i,stk_codes) = array2table(optimizer(0.1,risk_factors,factor_rtn',cov,factors,spec,exp_bound,active_bound)');%%%%%%
        
       disp(date);
    end
        
end


function x = optimizer(lambda, alpha_factors, alpha_factors_rtn, factor_cov, exposure, spk, exp_bound, active_bound)
%OPTIMIZER 此处显示有关此函数的摘要
%   此处显示详细说明

    bound_idx = exp_bound<Inf;
    bound_mtx = exposure(:,bound_idx);
    bound = exp_bound(bound_idx);
    
    alpha_factors(isnan(alpha_factors))=0;
    alpha_factors_rtn(isnan(alpha_factors_rtn))=0;

    % 这里还要考虑去NaN        
    n = size(exposure,1); %#ok<NASGU>
    cvx_begin
        variable x(n)
        maximize(alpha_factors_rtn' * alpha_factors' * x - lambda * quad_form(exposure' * x,factor_cov) - lambda * sum(spk .* x))
        subject to
        	%x >= 0; %#ok<VUNUS>
            sum(x) == 0; %#ok<EQEFF>
            -bound <= bound_mtx' * x <= bound; %#ok<VUNUS>
            -active_bound <= x <= active_bound; %#ok<VUNUS>
    cvx_end


end

% 从东方金工的模型结果中读取的股票代码转为SH600018这种格式
function stk_codes = df_stk_codes(stk_num)

    stk_codes = cell(length(stk_num),1);
    for i=1:length(stk_num)
        stk_str = num2str(stk_num(i));
        if(length(stk_str)<6)
            stk_str = [repmat('0',1,8-length(stk_str)),stk_str]; %#ok<AGROW>
            stk_str(1:2) = 'SZ';
        else
            if(stk_str(1)=='6' || stk_str(1)=='T') % 还有个T00018是上港集箱后来退市, 不过东方的数据应该没影响
                stk_str = ['SH',stk_str]; %#ok<AGROW>
            else
                stk_str = ['SZ',stk_str]; %#ok<AGROW>
            end
        end
        stk_codes(i) = {stk_str};
    end

end

