function f = cal_turn_ewma_single( r,s,D,HL)
    % length(r) 必须等于D
    % s =1 则表示停盘

    t = ((0.5*ones(1,D)).^(1/HL)).^(D:-1:1);
    w  = sqrt(t'/sum(t));    
    
    r(s==1,:)=[];
    w(s==1,:)=[]; w = w/sum(w);
    
    tmp = (r-sum(r.*w.*w));
    f = sqrt(sum(tmp.*tmp.*w.*w));

end

