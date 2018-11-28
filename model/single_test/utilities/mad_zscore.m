% MAD去极值

function f = mad_zscore(style,cap)
    
    f = nan(length(style),1);
    
    notnan = (~isnan(style)) & (~isnan(cap));
    x = style(notnan);
    cap = cap(notnan);
    
    mn = nansum(x.*cap)/nansum(cap);
    sd = nanstd(x);
    
    f(notnan) = rm_outlier(x); % 去极值
    
    f = (f - mn)/sd;  % 正态化   
    
end

function f = rm_outlier(x)

    f = x;

    md = median(x);
    % 超过1.483倍的偏离中值距离的中值则为outlier
    mad = 1.483 * median(abs(x-md));
    
    % 把极值拉回范围内
    f(x>md+mad) = md+mad;
    f(x<md-mad) = md-mad;

end

