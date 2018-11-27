function    [q1_,q2_,d] = m_tables(varargin)
      
    % 取两个table重合的那些交易日
    % varargin: q1,d1,q2,d2..
         
    [~,ia,ib] = intersect(d1,d2);
    d = d1(ia);
    q1_  = q1(ia,:);
    q2_  = q2(ib,:);
    %  q  = q1_./q2_;
end