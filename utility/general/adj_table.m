function  X  = adj_table(X)
       for i = 1: size(X,2)
            idx = find(isnan(X(:,i)));
            idx(idx==1)=[];
            for  j = length(idx):-1:1
                X(idx(j),i) =  X(idx(j)-1,i);
            end

            for  j = 1:length(idx)
                X(idx(j),i) =  X(idx(j)-1,i);
            end

            idx = find(isnan(X(:,i)));
            idx(idx==size(X,1))=[]; 
            for  j = length(idx):-1:1
                X(idx(j),i) =  X(idx(j)+1,i);
            end

            for  j = 1:length(idx)
                X(idx(j),i) =  X(idx(j)+1,i);
            end
       end   

end