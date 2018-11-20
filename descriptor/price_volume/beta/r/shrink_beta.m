function shrink_beta(beta_file,index_file,p,a,T,N,D,HL,adj_prices,is_suspended,ipo_dates)
%        beta_file = 'betawinda.h5';
%        beta_col  = '/ba';
%        se_col  = '/sa';
%        index_file = 'windA.h5';
       
       tgt_file = [a.output_data_path,'\stk_',beta_file,'.h5'];
       [idx_stk,loc_stk,idx_dt,loc_dt,exist_flag] = check_exist_h5(tgt_file,p);
       
        if all(idx_stk)&&all(idx_dt)  %不需要更新
           return;
        end
             
       tnames = {'/b','/tvol','/tskew','/tvol_ewma', '/tskew_ewma',...
                 '/ivol',  '/iskew', '/ivol_ewma', '/iskew_ewma',...
                 '/rng',  '/rmin6', '/rmax6', '/t120','/t240'}';
       for i = 1 : length(tnames)
           eval([tnames{i}(2:end),'i = h5read([a.output_data_path, ','''\',beta_file,'.h5'']',',''',tnames{i},''');'])
       end
              
       index_lv   = h5read([a.input_data_path,'\descriptors\',index_file],'/close');
       index_d    = datenum_h5(h5read([a.input_data_path,'\descriptors\',index_file],'/date'));
   
       index_lev = zeros(T,1);
       [~,loc1,loc2] = intersect(p.all_trading_dates,index_d);
       index_lev(loc1,:) = index_lv(loc2,:);

      [b,tvol,tskew,tvol_ewma,tskew_ewma,...
             ivol,iskew,ivol_ewma,iskew_ewma,...
             rng,rmin6,rmax6,t120,t240] = deal( NaN(T,N));
       
       if exist_flag==0      
           S = find(p.all_trading_dates>=datenum(2005,1,1),1,'first')+ D+1;
       elseif exist_flag==1
        %   b(idx_dt,idx_stk)  = h5read(tgt_file, '/stk_beta');  
           for i = 1 : length(tnames)
               eval([tnames{i}(2:end), '(idx_dt,idx_stk) = h5read(beta_file, ''',tnames{i},''');'])
           end
           S = find(loc_dt==0,1,'first');
       end
       
       
       for  i  = S  : T
        %  tic;
           for j = 1: N
               if  p.all_trading_dates(i)>ipo_dates(j)
                   Y     = adj_prices(i-D:i,j);
                   IND   = index_lev(i-D:i);
                   sus   = is_suspended(i-D:i,j);
             
                       y     = Y(2:end)./Y(1:end-1)-1;  y(isnan(y))=0;
                       ind   = IND(2:end)./IND(1:end-1)-1;  % 指数 
                       tao = sum(sus)/length(sus);%  停牌率
                       
                       
                      [tvol_ewma_,tskew_ewma_,w] = cal_vol_ewma_single(y,D,HL);                       
                      tvol_  = std(y)*sqrt(250); 
                      tskew_ = skewness(y); 
                    
                       mdl = fitlm(array2table([w.*y,w.*ind],  'VariableNames',{'y','x'}), 'ResponseVar','y','Intercept',true);
                       b_ = mdl.Coefficients.Estimate(end);    
                       
                       mdl = fitlm(array2table([y,ind],  'VariableNames',{'y','x'}), 'ResponseVar','y','Intercept',true);
                       ivol_ = std(mdl.Residuals.Raw)*sqrt(250);
                       iskew_ = skewness(mdl.Residuals.Raw);              
                       [ivol_ewma_,iskew_ewma_,~]= cal_vol_ewma_single(mdl.Residuals.Raw,D,HL);
               
                       ind1 = sort(y);
                       rmin6_ = mean(ind1(1:6));
                       rmax6_ = mean(ind1(end-5:end));
               
                       cum = cumprod(1+y);
                       rng_ = max(y)/min(y) - 1;
                       t120_ = mean(cum(end-4:end))/mean(cum(end-119:end));
                       t240_ = mean(cum(end-4:end))/mean(cum(end-239:end));
                       
                       
                      for k = 1 : length(tnames)
                          eval([tnames{k}(2:end), '(i,j) = (1-tao*tao*tao)*',tnames{k}(2:end),'_ + tao*tao*tao*',tnames{k}(2:end),'i(i,j);'])
                      end
                       
               end
           end
          %toc;
       end
       
       hdf5write([a.output_data_path,'\stk_',beta_file,'.h5'],   'b', b,...
                           '/tvol', tvol, '/tskew',tskew, '/tvol_ewma', tvol_ewma, '/tskew_ewma',tskew_ewma,...
                 '/ivol', ivol, '/iskew',iskew, '/ivol_ewma', ivol_ewma, '/iskew_ewma',iskew_ewma,...
                 '/rng', rng, '/rmin6',rmin6, '/rmax6', rmax6, '/t120',t120,'/t240',t240,...
                 '/date',p.all_trading_dates_, '/stk_code',p.stk_codes_);  
  
end