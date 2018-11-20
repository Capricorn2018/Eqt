function ret = intersectvecs(varargin)
    ret = varargin{1};
    for k = 2:nargin
        ret = intersect(ret, varargin{k});
    end
end