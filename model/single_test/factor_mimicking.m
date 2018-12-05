function weight_table = factor_mimicking(a,rebalance_dates,style_table,markcap_table,risk_factor_names)
    
    % factor mimicking portfolio
    % a: ���ڴ�������ݵ�·��
    % style_table: һ��table, ��һ����datenum, ֮����ÿ�ն�Ӧ���ӽ�������
    % risk_factor_names: ��Ҫ�����Ի��ķ�����������, ����'beta'

    %%
    % ��ֻ����һ��ָ���ɷַ�Χ��������, ��ֻ��Ҫ��style_table�е�����Ʊ����ΪNaN����
    %% ����
    % ���и�����, ����style�ǵ���������̬��, risk factorsȴ����risk֮ǰ��ȫ�г���Χ������̬��
    %%
    
    % ��ʼ��weight
    weight = nan(rebalance_dates,width(style_table)-1);    
    weight_table = [array2table(rebalance_dates),array2table(weight)];
    weight_table.Properties.VariableNames = style_table.Properties.VariableNames;
    
    % ����ѭ��
    for i=1:length(dt)
        
       date = datestr(rebalance_dates(i),'yyyy-mm-dd'); 
       % a.regression�Ƕ�ȡ�ع����þ�����ļ��е�ַ
       % ��ʱ����D:\Capricorn\model\risk\regression\
       filename = [a.single_test.regression,'\Index0_',date,'.mat'];
       
       % �ж��ļ��Ƿ����, ������ֱ������һ��ѭ��
       if(exist(filename,'file')==2)
           load(filename);
       else
           continue;
       end
       
       % �ӻع������ж�ȡ��Ӧ�ķ�������, �������޴�������������һ��ѭ��
       try
           risk_factors = table2array(pre_reg(:,risk_factor_names));  %#ok<NODEF>
       catch
           continue;
       end       
       
       % ��ÿ�ж��п�ֵ��������һ��ѭ��
       if(all(any(isnan(risk_factors),2)))
           continue;
       end       
       
       % �ӷ������Ӿ����ж�ȡ���չ�Ʊ����
       stk_codes = pre_reg.Properties.RowNames;
       
       % ��ȡstyle��ͬ�������Ʊ
       j = find(rebalance_dates(i),dt,'first');
       style = style_table(j,stk_codes);
       style = table2array(style)';
       cap = markcap_table(j,stk_codes);
       cap = table2array(cap)';
       
       % ����factor mimicking portfolio
       weight_table(i,stk_codes) = array2table(factor_mmck(style,cap,risk_factors)');
        
    end
        
end


% ���ûع鷽���� f = H' * r ��ȷ����H, ÿһ����һ�����Ӷ�Ӧ��fmp
% style: ��Ҫ����������, ����ֻҪ ԭ ʼ �� �� ����
% risk_factors�����������risk model�����ֳɵĻع����
% weight_array: ��Ӧÿֻ��Ʊ��weight, ͨ����ÿֻ��Ʊ������ֵ����ͨ��ֵ
function fm = factor_mmck(style, cap, risk_factors)

    %if(nargin==2)
    %   weight_array = ones(length(style),1); 
    %end
    
    % ȥNaN����
    non_nan = (~isnan(style)) & (~any(isnan(risk_factors),2)) & (~isnan(cap));
    
    style = style(non_nan);
    cap = cap(non_nan);
    weight = sqrt(cap);
    
    z = mad_zscore(style,cap);
    % ��������ع��еľ���, �������������ҵ��������Ҫ�ӵ�һ��1
    X = [ones(length(z),1),z,risk_factors];
    
    X = X(non_nan,:);

    % W���ع鷽���е�weight, ͨ����markcap
    W = diag(weight);
    
    % ����� H = (X' * W * X)^(-1) * X' * W
    H = (X' * W * X) \ (X'*W);
    
    fm = nan(length(style),1);
    % ȡ��2�м�style��Ӧ��factor mimicking portfolio
    fm(non_nan) = H(2,:);

end

