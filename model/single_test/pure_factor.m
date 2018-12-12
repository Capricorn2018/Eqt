% ���㴿�������Ȩ��, ����style�ı�¶��1, risk factor����ҵ��¶��Ϊ0����С�������
%%
% ��ֻ����һ��ָ���ɷַ�Χ��������, ��ֻ��Ҫ��style_table�е�����Ʊ����ΪNaN����
%% ����
% ���и�����, ����style�ǵ���������̬��, risk factorsȴ����risk֮ǰ��ȫ�г���Χ������̬��
%%
function weight_table = pure_factor(a,rebalance_dates,style_table,markcap_table,risk_factor_names)

    dt = table2array(style_table(:,1));

    % ��ʼ��weight
    weight = nan(length(rebalance_dates),width(style_table)-1);    
    weight_table = [array2table(rebalance_dates),array2table(weight)];
    weight_table.Properties.VariableNames = style_table.Properties.VariableNames;
    
    % ����ѭ��
    for i=1:length(rebalance_dates)
        
       % �����ַ���
       date = datestr(rebalance_dates(i),'yyyy-mm-dd'); 
       % a.regression�Ƕ�ȡ�ع����þ�����ļ��е�ַ
       % ��ʱ����D:\Capricorn\model\risk\regression\
       filename = [a.single_test.regression,'\Index0_',date,'.mat'];
       
       % �ж��ļ��Ƿ����
       if(exist(filename,'file')==2)
           load(filename);
       else
           continue;
       end
       
       % try catch���⵱�ն�Ӧ�ķ������Ӳ�����
       try
           risk_factors = table2array(pre_reg(:,risk_factor_names));  %#ok<NODEF>
       catch
           continue;
       end
       
       % �����𹤷������������ļ���, ����py��������
       % cov����D;\Capricorn\model\dfquant_risk\cov\��
       % risk factors����D:\Capricorn\model\dfquant_risk\factors\��
       % spec����D:\Capricorn\model\dfquant_risk\spec��
       % �����ַ�������yyyymmdd��ʽ
       date = datestr(rebalance_dates(i),'yyyymmdd'); 
       cov_filename = [a.single_test.dfquant_risk,'\cov\cov_',date,'.csv'];
       factor_filename = [a.single_test.dfquant_risk,'\factors\risk_factors_',date,'.csv'];
       spec_filename = [a.single_test.dfquant_risk,'\spec\spec_',date,'.csv'];
       
       if(exist(cov_filename,'file')==2 && exist(factor_filename,'file')==2 && exist(spec_filename,'file')==2)
           cov = readtable(cov_filename);
           spec = readtable(spec_filename);
           factors = readtable(factor_filename);
           
           % �Ѷ����������е������ƴ�����ת��SH600018���ָ�ʽ
           stk_num = factors(2:end,1);
           stk_num = table2array(stk_num);
           stk_codes = df_stk_codes(stk_num);
           
           % ����������
           cov = table2array(cov(2:end,2:end));
           spec = table2array(spec(:,2));
           factors = table2array(factors(2:end,2:end));
           
           % ����stk_cov����Ʊ��cov����, ������������SH600018��ʽ��Ʊ����
           stk_cov = nan(width(style_table));
           stk_cov = array2table(stk_cov,'VariableNames',style_table.Properties.VariableNames,'RowNames',style_table.Properties.VariableNames);
           
           % �Ӷ����������м����Ʊ��cov
           df_stk_cov = factors * cov * factors' + diag(spec);
           
           % �ø�ʽ����Ĺ�Ʊ������indexing
           stk_cov(stk_codes,stk_codes) = array2table(df_stk_cov);
           
           tbl_factors = array2table(factors,'RowNames',stk_codes);
           tbl_spec = array2table(spec,'RowNames',stk_codes);
           
           
       else
           continue;
       end
       
       
       if(all(any(isnan(risk_factors),2)))
           continue;
       end       
       
       % ���ջع�����еĹ�Ʊ����
       stk_codes = pre_reg.Properties.RowNames;
       
       % �ù�Ʊ����ɸѡstyle����Ҫ������
       % ��ȡstyle��ͬ�������Ʊ
       j = find(ismember(dt,rebalance_dates(i)),1,'first');
       style = style_table(j,stk_codes);
       style = table2array(style)';
       cap = markcap_table(j,stk_codes);
       cap = table2array(cap)';
       
       % ��stk_codes��������risk model�����indexing
       factors = tbl_factors(stk_codes,:);
       factors = table2array(factors);
       spec = tbl_spec(stk_codes,1);
       spec = table2array(spec);
       
       % �Ż����
       %weight_table(i,stk_codes) = array2table(minvol_opt(style,cap,risk_factors,stk_cov)');
       weight_table(i,stk_codes) = array2table(minvol_opt_test(style,cap,risk_factors,factors,cov,spec)');%%%%%%
        
       disp(date);
    end
        
end

% �Ӷ����𹤵�ģ�ͽ���ж�ȡ�Ĺ�Ʊ����תΪSH600018���ָ�ʽ
function stk_codes = df_stk_codes(stk_num)

    stk_codes = cell(length(stk_num),1);
    for i=1:length(stk_num)
        stk_str = num2str(stk_num(i));
        if(length(stk_str)<6)
            stk_str = [repmat('0',1,8-length(stk_str)),stk_str]; %#ok<AGROW>
            stk_str(1:2) = 'SZ';
        else
            if(stk_str(1)=='6' || stk_str(1)=='T') % ���и�T00018���ϸۼ����������, ��������������Ӧ��ûӰ��
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
function w = minvol_opt_test(style, cap, risk_factors, factors,factor_cov,spec)
    
    % ��ʼ��Ȩ�ؽ��
    w = zeros(length(style),1);
    
    % ȡ��������nan���в�ȥ��
    notnan_risk_factors = ~any(isnan(risk_factors),2);
    notnan_style = ~isnan(style);
    notnan_cap = ~isnan(cap);
    notnan_spec = ~isnan(spec);
    %notnan_cov = ~any(isnan(stk_cov),2) & ~any(isnan(stk_cov),1)';
    
    % û��NaN���ֵ���
    notnan_all = notnan_risk_factors & notnan_style & notnan_cap & notnan_spec;
    
    % ȡ��������ع����
    style = style(notnan_all);
    risk_factors = risk_factors(notnan_all,:);
    cap = cap(notnan_all);
    %stk_cov = stk_cov(notnan_all,notnan_all);
    factors = factors(notnan_all,:);
    factors(isnan(factors)) = 0;
    spec = spec(notnan_all,:);
    
    style = mad_zscore(style,cap);
    % ���������Ҫ��risk factorҲ����̬��
        
    % ���ﻹҪ����ȥNaN        
    n = length(style); %#ok<NASGU>
    cvx_begin
        variable x(n)
        minimize(quad_form(factors'*x,factor_cov)+sum(spec.*x.*x))
        subject to
        	%x >= 0; %#ok<VUNUS>
            risk_factors' * x == 0; %#ok<EQEFF>
            style' * x == 1; %#ok<EQEFF>
    cvx_end
    
    % ���
    w(notnan_all) = x;
    
end




% minimum variance�����ӵ��Ż�����, ����û��ʹ�óͷ����Ż�
% style: ���滯�������
% risk_factors: ���滯��ķ������Ӿ���
% sectors: ��¼ÿ�չ�Ʊ������ҵ�ľ���
% markcap: ÿ����ֵ����
% stk_cov: ��Ʊ��Э�������, ������factor cov��residual vol�����
function w = minvol_opt(style, cap, risk_factors, stk_cov)
    
    % ��ʼ��Ȩ�ؽ��
    w = zeros(length(style),1);
    
    % ȡ��������nan���в�ȥ��
    notnan_risk_factors = ~any(isnan(risk_factors),2);
    notnan_style = ~isnan(style);
    notnan_cap = ~isnan(cap);
    notnan_cov = ~any(isnan(stk_cov),2) & ~any(isnan(stk_cov),1)';
    
    % û��NaN���ֵ���
    notnan_all = notnan_risk_factors & notnan_style & notnan_cov & notnan_cap;
    
    % ȡ��������ع����
    style = style(notnan_all);
    risk_factors = risk_factors(notnan_all,:);
    cap = cap(notnan_all);
    stk_cov = stk_cov(notnan_all,notnan_all);
    
    style = mad_zscore(style,cap);
    % ���������Ҫ��risk factorҲ����̬��
        
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

