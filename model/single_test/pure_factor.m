% ���㴿�������Ȩ��, ����style�ı�¶��1, risk factor����ҵ��¶��Ϊ0����С�������
function weight_table = pure_factor(a,style_table,risk_factor_names)

    dt = style_table(:,1);
    dt = table2array(dt);
    
    weight = nan(height(style_table),width(style_table)-1);
    
    weight_table = [style_table(:,1),array2table(weight)];
    weight_table.Properties.VariableNames = style_table.Properties.VariableNames;
    
    for i=1:length(dt)
        
       date = datestr(dt(i),'yyyy-mm-dd'); 
       % a.regression�Ƕ�ȡ�ع����þ�����ļ��е�ַ
       % ��ʱ����D:\Capricorn\model\risk\regression\
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
       cov_filename = ['D:\Capricorn\model\dfquant_risk\cov\cov_',date,'.csv'];
       factor_filename = ['D:\Capricorn\model\dfquant_risk\factors\risk_factors_',date,'.csv'];
       spec_filename = ['D:\Capricorn\model\dfquant_risk\spec\spec_',date,'.csv'];
       if(exist(cov_filename,'file')==2 && exist(factor_filename,'file')==2 && exist(spec_filename,'file')==2)
           cov = readtable(cov_filename);
           spec = readtable(spec_filename);
           factors = readtable(factor_filename);
           
           stk_num = factors(2:end,1);
           
           stk_num = table2array(stk_num);
           stk_codes = df_stk_codes(stk_num);
           
           cov = table2array(cov(2:end,2:end));
           spec = table2array(spec(:,2));
           factors = table2array(factors(2:end,2:end));
           
           stk_cov = nan(width(style_table));
           stk_cov = array2table(stk_cov,'VariableNames',style_table.Properties.VariableNames,'RowNames',style_table.Properties.VariableNames);
           
           df_stk_cov = factors * cov * factors' + diag(spec);
           
           stk_cov(stk_codes,stk_codes) = array2table(df_stk_cov);
           
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
       
       stk_cov = stk_cov(stk_codes,stk_codes);
       stk_cov = table2array(stk_cov);
       
       weight_table(i,stk_codes) = array2table(minvol_opt(style,risk_factors,stk_cov)');
        
       disp(i);
    end
    
end

function stk_codes = df_stk_codes(stk_num)

    stk_codes = cell(length(stk_num),1);
    for i=1:length(stk_num)
        stk_str = num2str(stk_num(i));
        if(length(stk_str)<6)
            stk_str = [repmat('0',1,8-length(stk_str)),stk_str]; %#ok<AGROW>
            stk_str(1:2) = 'SZ';
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


% minimum variance�����ӵ��Ż�����, ����û��ʹ�óͷ����Ż�
% style: ���滯�������
% risk_factors: ���滯��ķ������Ӿ���
% sectors: ��¼ÿ�չ�Ʊ������ҵ�ľ���
% markcap: ÿ����ֵ����
% stk_cov: ��Ʊ��Э�������, ������factor cov��residual vol�����
function w = minvol_opt(style, risk_factors, stk_cov)
    
    % ��ʼ��Ȩ�ؽ��
    w = zeros(length(style),1);
    
    % ȡ��������nan���в�ȥ��
    notnan_risk_factors = ~any(isnan(risk_factors),2);
    notnan_style = ~any(isnan(style),2);
    
    notnan_cov = ~any(isnan(stk_cov),2) & ~any(isnan(stk_cov),1)';
    
    % û��NaN���ֵ���
    notnan_all = notnan_risk_factors & notnan_style & notnan_cov;
    
    % ȡ��������ع����
    style = style(notnan_all);
    risk_factors = risk_factors(notnan_all,:);
    
    stk_cov = stk_cov(notnan_all,notnan_all);
        
    %javaaddpath 'D:\Program Files\Mosek\8\tools\platform\win64x86\bin\mosekmatlab.jar'
    % ��mosek solver
    %cvx_solver Mosek;
        
    % ���ﻹҪ����ȥNaN        
    n = length(style); %#ok<NASGU>
    cvx_begin
        variable x(n)
        minimize(quad_form(x,stk_cov))
        subject to
        	%x >= 0; %#ok<VUNUS>
            risk_factors' * x == 0; %#ok<EQEFF>
            style' * x == 1; %#ok<EQEFF>
    cvx_end
    
    % ���
    w(notnan_all) = x;
    
end
