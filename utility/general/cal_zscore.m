function [ zscores ,outliers] = cal_zscore(input_vector,weight_vector)


    %  version: 2018/8/22
    % boxplot去outlier并正态化, 参见东方证券研报
    
    weight_vector(weight_vector<=0) = NaN; 
    idx_nan  = isnan(input_vector);
    not_nan  = input_vector(~idx_nan);
    
    
    mu     = nansum(input_vector.*weight_vector/nansum(weight_vector));
    sigma  = std(input_vector(~idx_nan));
    
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
    end
     
    if sigma>0
       zscores = (input_vector - mu)/sigma;
    end
end
