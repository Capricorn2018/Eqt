% 计算纯因子组合权重, 即对style的暴露是1, risk factor和行业暴露都为0的最小风险组合
%%
% 若只想在一个指数成分范围内做分析, 则只需要把style_table中的其他票都设为NaN即可
%% 问题
% 还有个问题, 这里style是单独做的正态化, risk factors却是做risk之前在全市场范围做的正态化
%%
function weight_table = pure_factor(a,rebalance_dates,style_table,markcap_table,risk_factor_names)

    dt = table2array(style_table(:,1));

    % 初始化weight
    weight = nan(length(rebalance_dates),width(style_table)-1);    
    weight_table = [array2table(rebalance_dates),array2table(weight)];
    weight_table.Properties.VariableNames = style_table.Properties.VariableNames;
    
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
           
           % 定义stk_cov即股票间cov矩阵, 行名列名都用SH600018格式股票代码
           stk_cov = nan(width(style_table));
           stk_cov = array2table(stk_cov,'VariableNames',style_table.Properties.VariableNames,'RowNames',style_table.Properties.VariableNames);
           
           % 从东方金工数据中计算股票间cov
           df_stk_cov = factors * cov * factors' + diag(spec);
           
           % 用格式化后的股票代码做indexing
           stk_cov(stk_codes,stk_codes) = array2table(df_stk_cov);
           
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
       
       % 用股票代码筛选style中需要的数据
       % 截取style中同样代码股票
       j = find(ismember(dt,rebalance_dates(i)),1,'first');
       style = style_table(j,stk_codes);
       style = table2array(style)';
       cap = markcap_table(j,stk_codes);
       cap = table2array(cap)';
       
       % 用stk_codes给东方的risk model结果做indexing
       factors = tbl_factors(stk_codes,:);
       factors = table2array(factors);
       spec = tbl_spec(stk_codes,1);
       spec = table2array(spec);
       
       % 优化求解
       %weight_table(i,stk_codes) = array2table(minvol_opt(style,cap,risk_factors,stk_cov)');
       weight_table(i,stk_codes) = array2table(minvol_opt_test(style,cap,risk_factors,factors,cov,spec)');%%%%%%
        
       disp(date);
    end
        
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


% minimum variance求纯因子的优化函数, 这里没有使用惩罚项优化
% style: 正规化后的因子
% risk_factors: 正规化后的风险因子矩阵
% sectors: 记录每日股票所在行业的矩阵
% markcap: 每日市值数据
% stk_cov: 股票间协方差矩阵, 可以用factor cov和residual vol算出来
function w = minvol_opt_test(style, cap, risk_factors, factors,factor_cov,spec)
    
    % 初始化权重结果
    w = zeros(length(style),1);
    
    % 取得所有有nan的行并去掉
    notnan_risk_factors = ~any(isnan(risk_factors),2);
    notnan_style = ~isnan(style);
    notnan_cap = ~isnan(cap);
    notnan_spec = ~isnan(spec);
    %notnan_cov = ~any(isnan(stk_cov),2) & ~any(isnan(stk_cov),1)';
    
    % 没有NaN出现的行
    notnan_all = notnan_risk_factors & notnan_style & notnan_cap & notnan_spec;
    
    % 取得最后进入回归的行
    style = style(notnan_all);
    risk_factors = risk_factors(notnan_all,:);
    cap = cap(notnan_all);
    %stk_cov = stk_cov(notnan_all,notnan_all);
    factors = factors(notnan_all,:);
    factors(isnan(factors)) = 0;
    spec = spec(notnan_all,:);
    
    style = mad_zscore(style,cap);
    % 这里可能需要把risk factor也给正态化
        
    % 这里还要考虑去NaN        
    n = length(style); %#ok<NASGU>
    cvx_begin
        variable x(n)
        minimize(quad_form(factors'*x,factor_cov)+sum(spec.*x.*x))
        subject to
        	%x >= 0; %#ok<VUNUS>
            risk_factors' * x == 0; %#ok<EQEFF>
            style' * x == 1; %#ok<EQEFF>
    cvx_end
    
    % 结果
    w(notnan_all) = x;
    
end




% minimum variance求纯因子的优化函数, 这里没有使用惩罚项优化
% style: 正规化后的因子
% risk_factors: 正规化后的风险因子矩阵
% sectors: 记录每日股票所在行业的矩阵
% markcap: 每日市值数据
% stk_cov: 股票间协方差矩阵, 可以用factor cov和residual vol算出来
function w = minvol_opt(style, cap, risk_factors, stk_cov)
    
    % 初始化权重结果
    w = zeros(length(style),1);
    
    % 取得所有有nan的行并去掉
    notnan_risk_factors = ~any(isnan(risk_factors),2);
    notnan_style = ~isnan(style);
    notnan_cap = ~isnan(cap);
    notnan_cov = ~any(isnan(stk_cov),2) & ~any(isnan(stk_cov),1)';
    
    % 没有NaN出现的行
    notnan_all = notnan_risk_factors & notnan_style & notnan_cov & notnan_cap;
    
    % 取得最后进入回归的行
    style = style(notnan_all);
    risk_factors = risk_factors(notnan_all,:);
    cap = cap(notnan_all);
    stk_cov = stk_cov(notnan_all,notnan_all);
    
    style = mad_zscore(style,cap);
    % 这里可能需要把risk factor也给正态化
        
    % 这里还要考虑去NaN        
    n = length(style); %#ok<NASGU>
    cvx_begin
        variable x(n)
        minimize(quad_form(x,stk_cov))
        subject to
        	%x >= 0; %#ok<VUNUS>
            risk_factors' * x == 0; %#ok<EQEFF>
            style' * x == 1; %#ok<EQEFF>
    cvx_end
    
    % 结果
    w(notnan_all) = x;
    
end

