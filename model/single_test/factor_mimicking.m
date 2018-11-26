% factor mimicking portfolio
function weight_table = factor_mimicking(a,style_table,risk_factor_names)

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
       
       if(all(any(isnan(risk_factors),2)))
           continue;
       end       
       
       stk_codes = pre_reg.Properties.RowNames;
       style = style_table(i,stk_codes);
       style = table2array(style);
       style = mad_zscore(style);
       
       weight_table(i,stk_codes) = array2table(factor_mmck(style,risk_factors)');
        
    end
    
end


% ���ûع鷽���� f = H' * r ��ȷ����H, ÿһ����һ�����Ӷ�Ӧ��fmp
% style: ��Ҫ����������, ����ֻҪ ԭ ʼ �� �� ����
% risk_factors�����������risk model�����ֳɵĻع����
% weight_array: ��Ӧÿֻ��Ʊ��weight, ͨ����ÿֻ��Ʊ������ֵ����ͨ��ֵ
function fm = factor_mmck(style, risk_factors, weight_array)

    if(nargin==2)
       weight_array = ones(length(style),1); 
    end
    
    z = mad_zscore(style);
    X = [ones(length(z),1),z,risk_factors];

    % ȥNaN����
    notnan_X = ~any(isnan(X),2);
    % ȥmarkcap��NaN
    notnan_weight = ~isnan(weight_array);    
    % ���е�NaN
    notnan_all = notnan_X & notnan_weight;
    
    weight = weight_array(notnan_all);
    X = X(notnan_all,:);

    % W���ع鷽���е�weight, ͨ����markcap
    W = diag(weight);
    
    % ����� H = (X' * W * X)^(-1) * X' * W
    H = (X' * W * X) \ (X'*W);
    
    fm = nan(length(z),1);
    % ȡ��2�м�style��Ӧ��factor mimicking portfolio
    fm(notnan_all) = H(2,:);

end
