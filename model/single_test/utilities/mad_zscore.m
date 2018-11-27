% MADȥ��ֵ

function f = mad_zscore(style,cap)

    style = style';
    
    f = nan(length(style),1);
    
    notnan = (~isnan(style)) & (~isnan(cap));
    x = style(notnan);
    cap = cap(notnan);
    
    f = (f - nansum(f.*cap)/nansum(cap))/nanstd(f);  % ��̬��

    f(notnan) = rm_outlier(x); % ȥ��ֵ
    
end

function f = rm_outlier(x)

    f = nan(length(x),1);

    md = median(x);
    % ����1.483����ƫ����ֵ�������ֵ��Ϊoutlier
    mad = 1.483 * median(abs(x-md));
    
    % �Ѽ�ֵ���ط�Χ��
    f(x>md+mad) = md+mad;
    f(x<md-mad) = md-mad;

end

