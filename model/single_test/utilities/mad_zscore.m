% MADȥ��ֵ

function f = mad_zscore(style)

    style = style';
    
    f = nan(length(style),1);
    
    x = style(~isnan(style));

    f(~isnan(style)) = rm_outlier(x); % ȥ��ֵ
    
    f = (f - nanmean(f))/nanstd(f);  % ��̬��

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

