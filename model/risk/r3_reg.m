function  r3_reg(p,a,K1,K2)
     warning('off')
     N = length(p.model.stk_codes);
     T = length(p.model.model_trading_dates);
     M = length(p.style.style);

%%

     adj_price     = h5read(p.file.stk,'/adj_prices')';   % T by N
     adj_rtn       = [nan(1,size(adj_price,2));adj_price(2:end,:)./adj_price(1:end-1,:)-1];
     adj_rtn(isnan(adj_rtn)) = 0;
    
     sectors        = h5read(p.file.ind,'/citics_stk_sectors_3')';

    for  idx_index = K1:K2
        S  = size(p.model.alpha_code.(['Index',num2str(idx_index)]),1);%  总行业的个数
        idx = find(p.model.model_trading_dates(1) == p.model.all_trading_dates);
        
        index_membs  =  p.model.indexmemb.(['index',num2str(idx_index)]); %　基准成分    
        index_membs_n   = table2array(index_membs);

        for i = 1 : T
           %    disp(i)

               load ([a.sector,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],...
                     'T_sector_today','T_stocks_cap_freecap_sector','T_sectors_cap_freecap','T_sus');
               load ([a.style,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],'T_sector_style');  

              % y = Xf +e  这里先算出 y
              idx_stk  = ismember( p.model.stk_codes1,T_sector_style.Properties.RowNames);              
              y = adj_rtn(idx,:)'; % 今天原始的
              y = y(idx_stk );  
              
              %　算X
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

              % prepare to regression  
              % X = [1,行业因子，风格因子 ]，先求行业因子    计算基准在各个行业上的分布             
              indexw0 =  index_membs_n(max(i-1,1),idx_stk)/100;  % 所有股票一天的权重情况
              
              % 计算基准在该天的行业分布情况
              u = zeros(S,1);
              all_sec = p.model.alpha_code.(['Index',num2str(idx_index)]);
              for j = 1 :S      
                 sub_codes =  p.model.ind_subcode.(cell2mat(all_sec.Eng(j)));
                 for k  = 1 : length(sub_codes)             
                     idx_s = sub_codes(k)==sectors(idx,:);
                     idx_s1  =  idx_s(:,idx_stk);
                     u(j,1)  =  u(j,1) + sum(indexw0(idx_s1));  
                 end
              end
           %   disp([i, sum(u,1)]);

              u1 = u(:,1)/sum(u(:,1)); %  实际权重
              u = u1;
              [~ ,id]  = max(u1);       id_ = (id==1:S); 

              % 用流通市值最大的行业做分母： r_n = f_c + \sum_{i=1}^{I-1} (X_{ni} - \frac{\omega_i}{\omega_I} X_{nI})f_i  +... + \epsilon_n
              x0  = table2array(T_sector) - repmat(u'/u(id),size(T_sector,1),1).*repmat(table2array(T_sector(:,id)),1,size(T_sector,2));
              ok_x_col_sector = ~(nan_sector|id_);              
              x0(:,~ok_x_col_sector) = NaN; 
              ok_x_col_style   = ~all(isnan(table2array(T_style)),1);
              x = [ones(size(x0,1),1),x0(:,ok_x_col_sector),table2array(pre_reg(:,ismember(pre_reg.Properties.VariableNames,p.style.style)))];
           
              %------- 麻痹的哥先这样了                
              x(isnan(x)) = 0; % 鉴于覆盖率还都比较高   
              %-------------
    
              w =  diag(sqrt(T_stocks_cap_freecap_sector.free_cap));  % 用上一天的自由流通市值加权
              
           %   index_memb_today  = p.model.stk_codes1(index_membs_n(i,:)>0)';
           %   [index_membs_today,ia,~]  = intersect(T_stocks_cap_freecap_sector.Properties.RowNames,index_memb_today);
           %   in_the_index = ismember((1:size(w,1))',ia);% 在指数里面的
               in_the_index = false(size(w,1),1);
               for m = 1 : N
                  if index_membs_n(i,m)>0
                     [~,loc] = ismember(p.model.stk_codes1(m),T_stocks_cap_freecap_sector.Properties.RowNames);
                     if loc>0
                       in_the_index(loc) = true;
                     end
                  end
                end   
           
              id2  = table2array(T_sus(T_sector_style.Properties.RowNames,'if_sus')) == 0; % 没停盘的  
              id1 = (y<0.105)&(y>-0.105); % 去掉涨幅涨幅跌幅大于10%的 
              ok_y = ~isnan(y);
              
              id_in_reg  = in_the_index&id2&id1&ok_y;
               
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
                      
              factor_rtn = array2table(table2array(f),'RowNames',cellstr(p.reg),'VariableNames',f.Properties.VariableNames);
              bm_weight_sector = p.model.alpha_code.(['Index',num2str(idx_index)]);
              bm_weight_sector.weight  = u;
              
%               idx_index_memb = ismember( p.model.stk_codes1,index_membs_today);             
%               bm_weight_stk = table(index_membs_n(i,idx_index_memb)'/100,'RowNames',p.model.stk_codes1(idx_index_memb)','VariableNames',{'bm_weight_stk'});
              
              f_  =  table2array(f)';
              res  = y - mtimes([ ones(height(T_sector),1),x1(:,ok_x_col_sectors),x2(:,ok_x_col_styles)],f_(~isnan(f_)));
              if sum(isnan(res)>0)
                  disp(['bug in ',num2str(i)])
              end
              residuals =  array2table(res,'RowNames',T_sector_today.Properties.RowNames, 'VariableNames', {'Raw'});
              
              save ([a.reggression,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],...
                     'factor_rtn','pre_reg','bm_weight_sector','residuals','mdl','w_','x_','y_'); 
              if i<T,idx = idx+1;end;
        end
    end  %end for idx_index = K1:K2
                    
end