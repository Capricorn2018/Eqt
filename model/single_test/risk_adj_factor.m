% ���(��ҵ)���Ե���
% style�Ǵ�������alpha����
% risk_factors�����ڻع�ľ���, ����ÿһ����һ������ȥ��ֵ�͹�һ���ķ�������, ����ҵ����

% ���ն���֤ȯ�콣�ε�����, ��������Ҫ����ҵ���Ժͷ������, ��������ֻ���������, ������

function res_factor = risk_adj_factor(style, risk_factors, weight_array)

    % ����Ĭ����weight_array��1/2�η���Ϊweight����ĶԽ���
    weight_matrix = diag(sqrt(weight_array));
    
    % ��risk_factors�м���һ�нؾ���
    X = [ones(size(risk_factors,1),1),risk_factors];

    % �����Իع�, ���matlab�������Զ�ȥ���п�ֵ����
    % ���ﲻ֪���ǲ���Ҫ�������Ƚ��ع�
    mdl = fitlm(weight_matrix * X, weight_matrix * style);
        
    % ��residual�ϳ���weight_matrix����������ս��
    weight_matrix_inv = diag(1/sqrt(weight_array));
    res_factor = mdl.Residuals * weight_matrix_inv;

end