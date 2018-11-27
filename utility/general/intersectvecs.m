function ret = intersectvecs(varargin)

    % 给定不定数个vec, 找互相重合的元素
    % 可以用来索引找重合股票代码
    
    ret = varargin{1};
    for k = 2:nargin
        ret = intersect(ret, varargin{k});
    end
end