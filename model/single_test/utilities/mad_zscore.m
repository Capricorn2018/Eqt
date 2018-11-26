% MAD去极值

function f = mad_zscore(style)

    style = style';
    
    f = nan(length(style),1);
    
    x = style(~isnan(style));

    f(~isnan(style)) = rm_outlier(x); % 去极值
    
    f = (f - nanmean(f))/nanstd(f);  % 正态化

end

function f = rm_outlier(x)

    f = nan(length(x),1);

    md = median(x);
    % 超过1.483倍的偏离中值距离的中值则为outlier
    mad = 1.483 * median(abs(x-md));
    
    % 把极值拉回范围内
    f(x>md+mad) = md+mad;
    f(x<md-mad) = md-mad;

end

