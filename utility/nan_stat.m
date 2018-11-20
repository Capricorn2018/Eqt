function [ non_nans,nans,means,stds,skews,kurts ] = nan_stat( input_matrix )
       
       [nans ,non_nans, means, stds,skews,kurts] = deal(zeros( size(input_matrix,2),1));

       for i  = 1 : size(input_matrix,2)
           idx_nan = isnan(input_matrix(:,i));
           nans(i,1)  = sum(idx_nan)/size(input_matrix,1);
           non_nans(i,1)  = 1 - nans(i,1);  % NaN  µÄ±ÈÀý
           
           vec_not_nan  = input_matrix(~idx_nan,1);
           means(i,1) = mean(vec_not_nan);
           stds(i,1)  = std(vec_not_nan);
           skews(i,1) = skewness(vec_not_nan);
           kurts(i,1)  = kurtosis(vec_not_nan);
       end


end

