% factor mimicking portfolio
% ���ûع鷽���� f = H' * r ��ȷ����H, ÿһ����һ�����Ӷ�Ӧ��fmp
% X: Ӧ���Ǿ������д���֮������Ӿ���, ����style�����滯��style��ȥ���ߡ�����ҵ����Լ����ȥ���ߴ���
% weight_array: ��Ӧÿֻ��Ʊ��weight, ͨ����ÿֻ��Ʊ������ֵ����ͨ��ֵ

function fm = factor_mimicking(style, risk_factors, weight_array)

    z = mad_zscore(style);
    X = [ones(length(z),1),z,risk_factors];

    % ȥNaN����
    notnan_X = ~any(isnan(X),2);
    % ȥmarkcap��NaN
    notnan_weight = ~isnan(weight_array);    
    % ���е�NaN
    notnan_all = notnan_X & notnan_weight;
    
    weight = weight_array(notnan_all);
    X = X(notnan_all,:);

    % W���ع鷽���е�weight, ͨ����sqrt(markcap)
    W = diag(weight);
    
    % ����� H = (X' * W * X)^(-1) * X' * W
    H = (X' * W * X) \ (X'*W);
    
    fm = nan(length(z),1);
    fm(notnan_all) = H(2,:);

end

