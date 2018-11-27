% MAD去极值

function f = mad_zscore(style,cap)

    style = style';
    
    f = nan(length(style),1);
    
    notnan = (~isnan(style)) & (~isnan(cap));
    x = style(notnan);
    cap = cap(notnan);
    
    f = (f - nansum(f.*cap)/nansum(cap))/nanstd(f);  % 正态化

    f(notnan) = rm_outlier(x); % 去极值
    
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

