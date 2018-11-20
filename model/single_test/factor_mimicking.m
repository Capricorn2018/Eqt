% factor mimicking portfolio
% ���ûع鷽���� f = H' * r ��ȷ����H, ÿһ����һ�����Ӷ�Ӧ��fmp
% X: Ӧ���Ǿ������д���֮������Ӿ���, ����style�����滯��style��ȥ���ߡ�����ҵ����Լ����ȥ���ߴ���
% markcap: ÿ����ֵ

function H = factor_mimicking(X, markcap)

    % ȥNaN
    notnan_X = any(~isnan(X),2);
    notnan_markcap = ~isnan(markcap);    
    notnan_all = notnan_X & notnan_markcap;
    
    markcap = markcap(notnan_all);
    X = X(notnan_all,:);

    % W���ع鷽���е�weight, ͨ����sqrt(markcap)
    W = diag(sqrt(markcap/nansum(markcap)));
    
    % ����� H = (X' * W * X)^(-1) * X' * W
    H = X' * W / (X' * W * X);

end

