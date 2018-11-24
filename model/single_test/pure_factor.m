% 计算纯因子组合权重, 即对style的暴露是1, risk factor和行业暴露都为0的最小风险组合
function weight_table = pure_factor(a,style_table,risk_factor_names)

    dt = style_table(:,1);
    dt = table2array(dt);
    
    weight = nan(height(style_table),width(style_table)-1);
    
    weight_table = [style_table(:,1),array2table(weight)];
    weight_table.Properties.VariableNames = style_table.Properties.VariableNames;
    
    for i=1:length(dt)
        
       date = datestr(dt(i),'yyyy-mm-dd'); 
       % a.regression是读取回归所用矩阵的文件夹地址
       % 暂时看是D:\Capricorn\model\risk\regression\
       filename = [a.regression,'\Index0_',date,'.mat'];
       if(exist(filename,'file')==2)
           load(filename);
       else
           continue;
       end
       
       try
           risk_factors = table2array(pre_reg(:,risk_factor_names));  %#ok<NODEF>
       catch
           continue;
       end
       
       date = datestr(dt(i),'yyyymmdd');
       cov_filename = ['D:\Capricorn\model\DFrisk\cov\cov_',date,'.csv'];
       factor_filename = ['D:\Capricorn\model\DFrisk\factors\risk_factors_',date,'.csv'];
       spec_filename = ['D:\Capricorn\model\DFrisk\spec\spec_',date,'.csv'];
       if(exist(cov_filename,'file')==2 && exist(factor_filename,'file')==2 && exist(spec_filename,'file')==2)
           cov = readtable(cov_filename);
           spec = readtable(spec_filename);
           factors = readtable(factor_filename);
           
           stk_num = cov(2:end,1);
           stk_codes = df_stk_codes(stk_num);
           cov = cov(2:end,2:end);
           spec = spec(2:end,2);
           factors = factors(2:end,2:end);
           
           stk_cov = nan(width(style_table));
           stk_cov = array2table(stk_cov,'VariableNames',style_table.Properties.VariableNames,'RowNames',style_table.Properties.VariableNames);
           
           df_stk_cov = factors' * cov * factors + diag(spec);
           
           stk_cov(stk_codes,stk_codes) = array2table(df_stk_cov);
           
           stk_cov = table2array(stk_cov);
           
       else
           continue;
       end
       
       
       if(all(any(isnan(risk_factors),2)))
           continue;
       end       
       
       stk_codes = pre_reg.Properties.RowNames;
       style = style_table(i,stk_codes);
       style = table2array(style);
       style = mad_zscore(style);
       
       weight_table(i,stk_codes) = array2table(minvol_opt(style,risk_factors,stk_cov)');
        
    end
    
end

function stk_codes = df_stk_codes(stk_num)

    stk_codes = cell(length(stk_num),1);
    for i=1:length(stk_num)
        stk_str = num2str(stk_num(i));
        if(length(stk_str)<6)
            stk_str = [repmat('0',1,6-length(stk_str)),stk_str]; %#ok<AGROW>
        else
            if(stk_str(1)=='6')
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
function w = minvol_opt(style, risk_factors, stk_cov)
    
    % 初始化权重结果
    w = zeros(length(style),1);
    
    % 取得所有有nan的行并去掉
    notnan_risk_factors = ~any(isnan(risk_factors),2);
    notnan_styles = ~any(isnan(styles),2);
    notnan_cov = ~any(isnan(cov),2);
    
    % 没有NaN出现的行
    notnan_all = notnan_risk_factors & notnan_styles & notnan_cov;
    
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
        	%x >= 0; %#ok<VUNUS>
            risk_factors * x == 0; %#ok<EQEFF>
            style * x == 1; %#ok<EQEFF>
    cvx_end
    
    % 结果
    w(notnan_all) = x.Value;
    
end

