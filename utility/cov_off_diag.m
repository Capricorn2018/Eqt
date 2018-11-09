function c = cov_off_diag(x,y,factor_vol_hl,factor_corr_hl)
         %  X and Y must be arrays and have same size
         %  c(I,J) = cov(X(:,I),Y(:,J)) 
        
         % Test example 1
         % x = [5   0  3  7; 7 -5  7  3;    NaN   2  8 10]
         % y = [5   0  4  NaN; NaN -5  7  NaN;  4  NaN 4 NaN ] 
         % cov_(x,y,2,1)
         
        %  Test example 2
        %  x1 = rand(100,1);
        %  cov_(x1,x1,1e8,1e8)
        %  var(x1,1)
        %  cov(x1,1)

%         if  ~all(size(x)==size(y))
%             error('x and y must have same size');
%         end
        
        t = size(x, 1); % number of ovservations
        n = size(x, 2); % number of factors
        c = NaN(n, 'like', x([])); 
 
        l_vol_hl        = (1/2)^(1/factor_vol_hl); % weight at t0,...,tn  = (1-lam)*lam^(n-1)
        l_corr_hl       = (1/2)^(1/factor_corr_hl);

        lam_l_vol_hl     =   power(l_vol_hl, ((t-1):-1:0))';
        lam_l_vol_hl     =   lam_l_vol_hl/sum(lam_l_vol_hl);
        lam_l_corr_hl    =   power(l_corr_hl,((t-1):-1:0))';
        lam_l_corr_hl    =   lam_l_corr_hl/sum(lam_l_corr_hl);
     
        for i = 1 : n  %  time consuming , should be improved
            for j = 1: n
                if i~=j
                   %c(i,j) = localcov_elementwise(x(:,i),y(:,j),lam_l_vol_hl);
                   % c(i,j) = cal_var(x(:,i),y(:,j),lam_l_vol_hl);
%                 else
%                   % c(i,j) = localcov_elementwise(x(:,i),y(:,j),lam_l_corr_hl);
                     c(i,j) = cal_var(x(:,i),y(:,j),lam_l_corr_hl);
                end
            end
        end
     
end


function c = localcov_elementwise(x,y,hl)
     
        % x and y must be a n*1 vector we have no error checking here
        nr_notnan = sum(~isnan(x), 1);

        xmean = sum(x, 1, 'omitnan');
        xmean = xmean ./ nr_notnan;
        xc = bsxfun(@minus, x, xmean);

        ymean = sum(y, 1, 'omitnan');
        ymean = ymean ./ nr_notnan;
        yc = bsxfun(@minus, y, ymean);
    
        c = nansum(hl.*xc.*yc);

        if all(isnan(x+y))
            c = NaN;
        end
        
end

function f = cal_var(x,y,hl)
      % x and y must be a n*1 vector we have no error checking here
         f =  sum((x - x.*hl).*(y - y.*hl).*hl);
     
end
