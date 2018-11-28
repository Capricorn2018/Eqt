% MADȥ��ֵ

function f = mad_zscore(style,cap)
    
    f = nan(length(style),1);
    
    notnan = (~isnan(style)) & (~isnan(cap));
    x = style(notnan);
    cap = cap(notnan);
    
    mn = nansum(x.*cap)/nansum(cap);
    sd = nanstd(x);
    
    f(notnan) = rm_outlier(x); % ȥ��ֵ
    
    f = (f - mn)/sd;  % ��̬��   
    
end

function f = rm_outlier(x)

    f = x;

    md = median(x);
    % ����1.483����ƫ����ֵ�������ֵ��Ϊoutlier
    mad = 1.483 * median(abs(x-md));
    
    % �Ѽ�ֵ���ط�Χ��
    f(x>md+mad) = md+mad;
    f(x<md-mad) = md-mad;

end

