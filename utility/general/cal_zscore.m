function [ zscores ,outliers] = cal_zscore(input_vector,weight_vector)


    %  version: 2018/8/22
    % boxplotȥoutlier����̬��, �μ�����֤ȯ�б�
    
    weight_vector(weight_vector<=0) = NaN; 
    idx_nan  = isnan(input_vector) | input_vector==-Inf | input_vector==Inf;
    not_nan  = input_vector(~idx_nan);
    
    zscores  = nan(size(input_vector,1),1);
    outliers = nan(size(input_vector,1),1);
    
    if  ~isempty(not_nan)
        % outlier treatment 
        % mad = median(abs(fi- median_f))
        % outlier : fi > median_f +3*1.4826*mad 
        %          or fi < median_f -3*1.4826*mad 
        mad = median(abs(not_nan  - median(not_nan)));
        ub = median(not_nan) + 3*1.4826*mad ;
        lb = median(not_nan) - 3*1.4826*mad ;

        outliers(input_vector>ub) = 1;           
        outliers(input_vector<lb) = 1;

        input_vector(input_vector<lb) = lb;
        input_vector(input_vector>ub) = ub;
    else
        zscores = nan(size(input_vector));
        return;
    end    
    
    mu     = nansum(input_vector(~idx_nan).*weight_vector(~idx_nan)/nansum(weight_vector(~idx_nan)));
    sigma  = std(input_vector(~idx_nan));
    
    if sigma>0
       zscores = (input_vector - mu)/sigma;
       zscores(input_vector==Inf | input_vector==-Inf) = 0; %%%%%%%%%%%%% ������Inf����0,�Ժ���˵��
    end
    
end
