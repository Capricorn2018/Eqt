function [v,skew] = cal_vol_ewma_single1( r,w)
    % length(r) ±ØÐëµÈÓÚD

  %  t = ((0.5*ones(1,D)).^(1/HL)).^(D:-1:1);
  %  w  = sqrt(t'/sum(t));    
    
    tmp = (r-sum(r.*w.*w));
    f = sqrt(sum(tmp.*tmp.*w.*w));
    v  = f*sqrt(250);
    skew = sum(tmp.*tmp.*tmp.*w.*w)/(f^3);

end

