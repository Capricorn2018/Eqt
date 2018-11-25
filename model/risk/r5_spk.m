


      N = length(p.model.stk_codes);
      T = length(p.model.model_trading_dates);
      M = length(p.style.style);
          
      D = max([p.spk.spk_N ,p.spk.nw_N,p.spk.vra_N]);
     
      
        for  idx_index = K1:K2     
             S  = size(p.model.alpha_code.(['Index',num2str(idx_index)]),1);%  总行业的个数
             index_membs  =  p.model.indexmemb.(['index',num2str(idx_index)]); %　基准成分    
             index_membs_n   = table2array(index_membs);
             [res_rtn_matrix,idx_res_rtn_matrix] = deal(NaN(length(p.model.all_trading_dates),N)); 

             for i = 1: length(p.model.all_trading_dates)
                 x = exist([a.reggression,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],'file');
                 if  x==2
                     load ([a.reggression,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'], 'residuals'); 
                     idx_t = ismember(p.model.stk_codes1,residuals.Properties.RowNames);
                     res_rtn_matrix(i,idx_t) = residuals.Raw';
                     idx_res_rtn_matrix(i,:) = idx_t;
                end
             end

             for i = 1 : T
                 if i>D+1
                    idx_dt = find(p.model.model_trading_dates(i)==p.model.all_trading_dates,1,'first');   
                    r_rtn   = res_rtn_matrix((idx_dt-p.spk.spk_N)  :idx_dt-1,idx_res_rtn_matrix(idx_dt,:)==1);  
                    nw_rtn  = res_rtn_matrix((idx_dt-p.spk.nw_N)  :idx_dt-1,idx_res_rtn_matrix(idx_dt,:)==1);  
                    h_rtn   = res_rtn_matrix((idx_dt-p.spk.h)  :idx_dt-1,idx_res_rtn_matrix(idx_dt,:)==1);  
                    
                    load ([a.reggression,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'], 'residuals','bm_weight_sector'); 
                  %% nw -adj 
                    [residuals.nw,residuals.ewma] = nw_adj_spk(r_rtn,nw_rtn,p);
                    residuals.nw = sqrt(residuals.nw);
                    residuals.ewma = sqrt(residuals.ewma);
                  
                  %% structured model
                    [residuals.gamma] = deal(NaN(height(residuals),1));
                    for j = 1 : height(residuals)
                        x = h_rtn(:,j); x = x(~isnan(x));
                        su = (1/1.35)*(quantile(x,0.75)-quantile(x,0.25));
                        zu = abs(std(x)/su - 1);
                        residuals.gamma(j,1) = min(1,max(0,(length(x)-60)/120))*min(1,max(0,exp(1-zu)));
                    end
                    
                    load ([a.sector,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],'T_sector_today','T_stocks_cap_freecap_sector','T_sus');
                    load ([a.style,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],'T_sector_style');  
                    
                    y = log(residuals.nw);
                    
                    T_sector = T_sector_style(:,~ismember(T_sector_style.Properties.VariableNames,p.style.style));
                    T_style  = T_sector_style(:,ismember(T_sector_style.Properties.VariableNames,p.style.style));

                    [~,loc]= ismember(p.model.ind_names.Eng,T_sector.Properties.VariableNames);       
                    T_sector = T_sector(:,T_sector.Properties.VariableNames(loc(loc>0)));

                    [~,loc]= ismember(p.style.style,    T_style.Properties.VariableNames);       
                    T_style = T_style(:,T_style.Properties.VariableNames(loc(loc>0)));
                    
                    nan_sector = sum(table2array(T_sector),1)<=0;  %如果所有股票都不属于这个行业, 要剔除。
                    ok_x_col_styles   = ~all(isnan(table2array(T_style)),1);
                    ok_x_col_sectors   = ~ nan_sector; 
                    x1 = table2array(T_sector);
                    x2 = table2array(T_style);              
                    %------- 麻痹的哥先这样了                
                    x1(isnan(x1)) = 0; % 鉴于覆盖率还都比较高   
                    x2(isnan(x2)) = 0; % 鉴于覆盖率还都比较高   
                    %-------------                         
                    % pre regression: store the factor exposures
                    pre_reg =  array2table([y,ones(height(T_sector),1),x1(:,ok_x_col_sectors),x2(:,ok_x_col_styles)],'RowNames',T_sector_today.Properties.RowNames,...
                                            'VariableNames', [{'y';'mkt'};T_sector.Properties.VariableNames(ok_x_col_sectors)';T_style.Properties.VariableNames(ok_x_col_styles)']);

                    u = bm_weight_sector.weight;
                    [~ ,id]  = max(u);       id_ = (id==1:S); 
                    
                    x0  = table2array(T_sector) - repmat(u'/u(id),size(T_sector,1),1).*repmat(table2array(T_sector(:,id)),1,size(T_sector,2));
                    ok_x_col_sector = ~(nan_sector|id_);  
                    x0(:,~ok_x_col_sector) = NaN; 
                    ok_x_col_style   = ~all(isnan(table2array(T_style)),1);
                    x = [ones(size(x0,1),1),x0(:,ok_x_col_sector),table2array(pre_reg(:,ismember(pre_reg.Properties.VariableNames,p.style.style)))];
                    x(isnan(x)) = 0;
                    
                    w =  diag(sqrt(T_stocks_cap_freecap_sector.free_cap));  % 用上一天的自由流通市值加权    
                     in_the_index = false(size(w,1),1);
                     for m = 1 : N
                         if index_membs_n(i,m)>0
                            [~,loc] = ismember(p.model.stk_codes1(m),T_stocks_cap_freecap_sector.Properties.RowNames);
                            if loc>0
                               in_the_index(loc) = true;
                            end
                         end
                     end                  
                    ok_y = ~isnan(y);
                    ok_gamma  = residuals.gamma ==1;
              
                    id_in_reg  = in_the_index&ok_y&ok_gamma;
               
                    w_ =  w(id_in_reg,id_in_reg) ;% 不在基准里面的回归没权重
                    x_ =  x(id_in_reg,:);
                    y_ =  y(id_in_reg,:);

                    tbl = array2table([ mtimes(w_,y_),mtimes(w_,x_)],'RowNames',T_sector_today.Properties.RowNames(id_in_reg),...
                                    'VariableNames', [{'y';'mkt'};T_sector.Properties.VariableNames(ok_x_col_sector)';p.style.style(ok_x_col_style)]);

                   if strcmp(p.reg,'ols')
                      mdl   = fitlm(tbl,'ResponseVar','y','Intercept',false);
                      if strcmp(lastwarn,'Regression design matrix is rank deficient to within machine precision.')
                         if min(sum(x1,2))>1, disp(min(sum(x1,2)));end;
                         lastwarn('')
                      end
                      f     = get_exp(T_sector,T_style, mdl,id,u);
                  else
                      mdl   = fitlm(tbl,'ResponseVar','y','Intercept',false,'RobustOpts','huber');
                      f     = get_exp(T_sector,T_style, mdl,id,u);
                   end
                      
                  residuals.str = p.spk.E0*exp(mtimes( table2array(pre_reg(:,2:end)),table2array(f)'));
                  residuals.structured  = residuals.gamma.*residuals.nw + (1-residuals.gamma).*residuals.str;
                    
                %% bayesian shrinkage
                   [residuals.sn,residuals.dn,residuals.gn,residuals.sh] = deal(NaN(height(residuals),1));
                  
                  G = p.spk.groups;
                  qtiles =  quantile(1:height(residuals),1/G:1/G:1);
                  [floorg,ceilg] = deal(G,1);
                  
                  T_cap = outerjoin(residuals,)
                  T_cap = sortrows(T_stocks_cap_freecap_sector,{'total_cap'});
                  for m = 1 : G
                     if m==1
                         floorg(m,1) = 1;
                     else
                         floorg(m,1) = floor(qtiles(m-1));
                     end
                     ceilg(m,1) = ceil(qtiles(m));
                  end
                    
                  %% vra
                 end  % end  if i>D+1          
             end
        end    % end for for  idx_index = K1:K2 