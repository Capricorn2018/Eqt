% ���(��ҵ)���Ե���
% style_table: ��������alpha����table, ��һ��������, ������SZ000001���ָ�ʽ
% risk_factors_names: cell, ���ڻع�����������������ʹ�õķ�����������, ��Ӧ����ģ�������е�����,
%                     ����'beta','bp','tcap'
%%
% ��ֻ����һ��ָ���ɷַ�Χ��������, ��ֻ��Ҫ��style_table�е�����Ʊ����ΪNaN����

%% ����
% 2018-11-21: ���ն���֤ȯ�콣�ε�����, ��������Ҫ����ҵ���Ժͷ������, ��������ֻ���������, ������
% ���и�����, ����style�ǵ���������̬��, risk factorsȴ����risk֮ǰ��ȫ�г���Χ������̬��
%%
function adj_style_table = risk_adj_factor(a,rebalance_dates,style_table,markcap_table,risk_factor_names)

    % ��ʼ�����
    adj_style = nan(length(rebalance_dates),width(style_table)-1);    
    adj_style_table = [array2table(rebalance_dates),array2table(adj_style)];
    adj_style_table.Properties.VariableNames = style_table.Properties.VariableNames;
    
    % ����ѭ���ع�
    for i=1:length(rebalance_dates)
       % �����ַ������ɶ�risk_factor���ļ���
       date = datestr(rebalance_dates(i),'yyyy-mm-dd'); 
       filename = [a.single_test.style,'\Index0_',date,'.mat'];
       
       % �ж��ļ��Ƿ����
       if(exist(filename,'file')==2)
           load(filename);
       else
           continue;
       end
       
       % try catchģ����⵱��û�д���ķ�������
       try
           risk_factors = table2array(T_sector_style(:,risk_factor_names)); %#ok<NODEF>
       catch
           continue;
       end
              
       % ��risk_factorÿһ�ж��п�ֵ���˳���һ��ѭ��
       if(all(any(isnan(risk_factors),2)))
           continue;
       end       
       
       % ��risk_factor�ж�ȡ���չ�Ʊ��
       stk_codes = T_sector_style.Properties.RowNames;
       
       % ��Ŀ��style�н�ȡrisk_factor��Ҳ���ڵĹ�Ʊ��
       j = find(ismember(style_table.DATEN,rebalance_dates(i)),1,'first');
       style = style_table(j,stk_codes);
       style = table2array(style)';
       cap = markcap_table(j,stk_codes);
       cap = table2array(cap)';
       %style = mad_zscore(style,cap);
       
       % �ع�ȡ�в���ս��
       adj_style_table(i,stk_codes) = array2table(calc_residual(style,cap,risk_factors)');
        
    end
    
end

% ��һ������ӽ���͵���ķ������Ӿ���, �ع����вrisk adjusted factor
% weightһ����sqrt(cap), �����Ȳ����Ǽ�Ȩ��Ĭ��Ϊ1
function res_factor = calc_residual(style, cap, risk_factors)

    %if(nargin==2)
    %   weight_array = ones(length(style),1); 
    %end
    
    res_factor = nan(length(style),1);

    non_nan = (~isnan(style)) & (~any(isnan(risk_factors),2)) & (~isnan(cap));
    style = style(non_nan);
    cap = cap(non_nan);
    weight = sqrt(cap);
    
    % ����raw factor��zscore
    % �����õ�MAD, risk model������boxplot
    zscore = mad_zscore(style,cap);
    
    % ��risk_factors�м���һ�нؾ���
    X = [ones(size(risk_factors,1),1),risk_factors];
   
    y = zscore .* weight;
    % �ع����Ҳÿһ�г���sqrt(cap)
    x = repmat(weight,1,size(X,2)) .* X(non_nan,:);

    % ���ﲻ֪���ǲ���Ҫ�������Ƚ��ع�
    [~,~,res] = regress(y,x);
        
    % ��residual�ϳ���weight_matrix����������ս��
    res_factor(non_nan) = res ./ weight;

end