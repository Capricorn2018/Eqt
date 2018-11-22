% ���(��ҵ)���Ե���
% style�Ǵ�������alpha����
% risk_factors�����ڻع�ľ���, ����ÿһ����һ������ȥ��ֵ�͹�һ���ķ�������, ����ҵ����

% 2018-11-21: ���ն���֤ȯ�콣�ε�����, ��������Ҫ����ҵ���Ժͷ������, ��������ֻ���������, ������

function adj_style_table = risk_adj_factor(a,style_table)

    dt = style_table(:,1);
    dt = table2array(dt);
    
    %style_array = table2array(style_table(:,2:end));
    
    adj_style = nan(height(style_table),width(style_table)-1);
    
    adj_style_table = [style_table(:,1),array2table(adj_style)];
    adj_style_table.Properties.VariableNames = style_table.Properties.VariableNames;
    
    for i=1:length(dt)
        
       date = datestr(dt(i),'yyyy-mm-dd'); 
       filename = [a.style,'Index0_',date,'.mat'];
       if(exist(filename,'file')==2)
           load(filename);
       else
           continue;
       end
       
       risk_factors = table2array(T_sector_style);
       risk_factors = risk_factors(:,[1:36,37,47]);
       if(all(any(isnan(risk_factors),2)))
           continue;
       end       
       
       stk_codes = T_sector_style.Properties.RowNames;
       style = style_table(i,stk_codes);
       style = table2array(style);
       style = mad_zscore(style);
       
       adj_style_table(i,stk_codes) = array2table(calc_residual(style,risk_factors)');
        
    end
    
end


function res_factor = calc_residual(style, risk_factors, weight_array)

    if nargin==2
       weight_array = ones(length(style),1); 
    end

    % ����raw factor��zscore
    % �����õ�MAD, risk model������boxplot
    zscore = mad_zscore(style);
    
    % ��risk_factors�м���һ�нؾ���
    X = [ones(size(risk_factors,1),1),risk_factors];

    % �����Իع�, ���matlab�������Զ�ȥ���п�ֵ����
    % ���ﲻ֪���ǲ���Ҫ�������Ƚ��ع�
    mdl = fitlm(repmat(weight_array,1,size(X,2)) .* X, weight_array .* zscore);
        
    % ��residual�ϳ���weight_matrix����������ս��
    res_factor = mdl.Residuals.Raw ./ weight_array;

end