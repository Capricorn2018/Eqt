function ret = intersectvecs(varargin)

    % ������������vec, �һ����غϵ�Ԫ��
    % ���������������غϹ�Ʊ����
    
    ret = varargin{1};
    for k = 2:nargin
        ret = intersect(ret, varargin{k});
    end
end