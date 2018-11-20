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
        S  = size(p.model.alpha_code.(['Index',num2str(idx_index)]),1);%  ����ҵ�ĸ���
        idx = find(p.model.model_trading_dates(1) == p.model.all_trading_dates);
        
        index_membs  =  p.model.indexmemb.(['index',num2str(idx_index)]); %����׼�ɷ�    
        index_membs_n   = table2array(index_membs);

        factor_rtn_matrix = NaN(T,S+M+1); % �г���1��+ ��ҵ(S) +���M)
        res_rtn_matrix    = NaN(T,N);

        for i = 1 : T
           %    disp(i)

               load ([a.sector,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],...
                     'T_sector_today','T_stocks_cap_freecap_sector','T_sectors_cap_freecap','T_sus');
               load ([a.style,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],'T_sector_style','T_des');  

              % y = Xf +e  ��������� y
              idx_stk  = ismember( p.model.stk_codes1,T_sector_style.Properties.RowNames);              
              y = adj_rtn(idx,:)'; % ����ԭʼ��
              y = y(idx_stk );  
              
              %����X
              T_sector = T_sector_style(:,~ismember(T_sector_style.Properties.VariableNames,p.style.style));
              T_style  = T_sector_style(:,ismember(T_sector_style.Properties.VariableNames,p.style.style));

              nan_sector = sum(table2array(T_sector),1)<=0;  %������й�Ʊ�������������ҵ, Ҫ�޳���
              
              ok_x_col_styles   = ~all(isnan(table2array(T_style)),1);
              ok_x_col_sectors   = ~ nan_sector;   
              
              x1 = table2array(T_sector);
              x2 = table2array(T_style);
              
              %------- ��Եĸ���������                
              x1(isnan(x1)) = 0; % ���ڸ����ʻ����Ƚϸ�   
              x2(isnan(x2)) = 0; % ���ڸ����ʻ����Ƚϸ�   
              %-------------
              
              
              % pre regression: store the factor exposures
              pre_reg =  array2table([y,ones(height(T_sector),1),x1(:,ok_x_col_sectors),x2(:,ok_x_col_styles)],'RowNames',T_sector_today.Properties.RowNames,...
                                    'VariableNames', [{'y';'mkt'};T_sector.Properties.VariableNames(ok_x_col_sectors)';p.style.style(ok_x_col_styles)]);
              
              
              % prepare to regression  
              % X = [1,��ҵ���ӣ�������� ]��������ҵ����    �����׼�ڸ�����ҵ�ϵķֲ�             
              indexw0 =  index_membs_n(max(i-1,1),idx_stk)/100;  % ���й�Ʊһ���Ȩ�����
              
              % �����׼�ڸ������ҵ�ֲ����
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

              u1 = u(:,1)/sum(u(:,1)); %  ʵ��Ȩ��
              u = u1;
              [~ ,id]  = max(u1);       id_ = (id==1:S); 

              % ����ͨ��ֵ������ҵ����ĸ�� r_n = f_c + \sum_{i=1}^{I-1} (X_{ni} - \frac{\omega_i}{\omega_I} X_{nI})f_i  +... + \epsilon_n
              x0  = table2array(T_sector) - repmat(u'/u(id),size(T_sector,1),1).*repmat(table2array(T_sector(:,id)),1,size(T_sector,2));
              ok_x_col_sector = ~(nan_sector|id_);              
              x0(:,~ok_x_col_sector) = NaN; 
              ok_x_col_style   = ~all(isnan(table2array(T_style)),1);
              x = [ones(size(x0,1),1),x0(:,ok_x_col_sector),table2array(T_sector_style(:,p.style.style(ok_x_col_style)))];
           
              %------- ��Եĸ���������                
              x(isnan(x)) = 0; % ���ڸ����ʻ����Ƚϸ�   
              %-------------
    
              w =  diag(sqrt(T_stocks_cap_freecap_sector.free_cap));  % ����һ���������ͨ��ֵ��Ȩ
              
              index_memb_today  = p.model.stk_codes1(index_membs_n(i,:)>0)';
              [index_membs_today,ia,~]  = intersect(T_stocks_cap_freecap_sector.Properties.RowNames,index_memb_today);
              in_the_index = ismember((1:size(w,1))',ia);% ��ָ�������
              id2  = table2array(T_sus(T_sector_style.Properties.RowNames,'if_sus')) == 0; % ûͣ�̵�  
              id1 = (y<0.105)&(y>-0.105); % ȥ���Ƿ��Ƿ���������10%�� 
              ok_y = ~isnan(y);
              
              id_in_reg  = in_the_index&id2&id1&ok_y;
              
 
              w_ =  w(id_in_reg,id_in_reg) ;% ���ڻ�׼����Ļع�ûȨ��
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
                  f    = get_exp(T_sector,T_style, mdl,id,u);
              else
                  mdl   = fitlm(tbl,'ResponseVar','y','Intercept',false,'RobustOpts','huber');
                  f     = get_exp(T_sector,T_style, mdl,id,u);
              end
           
              
              factor_rtn = array2table(table2array(f),'RowNames',cellstr(p.reg),'VariableNames',f.Properties.VariableNames);

              factor_rtn_matrix(i,:) = table2array(f);
              
              bm_weight_sector = p.model.alpha_code.(['Index',num2str(idx_index)]);
              bm_weight_sector.weight  = u;
              
              idx_index_memb = ismember( p.model.stk_codes1,index_membs_today);             
              bm_weight_stk = table(index_membs_n(i,idx_index_memb)'/100,'RowNames',p.model.stk_codes1(idx_index_memb)','VariableNames',{'bm_weight_stk'});
              
              f_  =  table2array(f)';
              res  = y - mtimes([ ones(height(T_sector),1),x1(:,ok_x_col_sectors),x2(:,ok_x_col_styles)],f_(~isnan(f_)));
              if sum(isnan(res)>0)
                  disp(['bug in ',num2str(i)])
              end
              res_rtn_matrix(i,idx_stk) = res';
              residuals =  array2table(res,'RowNames',T_sector_today.Properties.RowNames, 'VariableNames', {'Raw'});
              
              save ([a.reggression,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],...
                     'factor_rtn','pre_reg','bm_weight_sector','bm_weight_stk','residuals','mdl','w_','x_','y_'); 
              if i<T,idx = idx+1;end;
        end

        factor_rtns_matrix = array2table(factor_rtn_matrix,'RowNames',cellstr(datestr(p.model.model_trading_dates,29)),'VariableNames',f.Properties.VariableNames);
        res_rtns_matrix    = array2table(res_rtn_matrix,'RowNames',cellstr(datestr(p.model.model_trading_dates,29)),'VariableNames',p.model.stk_codes1);
        save ([a.backtest,'\regression\regression_stats_','Index',num2str(idx_index),'.mat'],'factor_rtn_matrix','factor_rtns_matrix','res_rtn_matrix','res_rtns_matrix'); 
    end  %end for idx_index = K1:K2
   %%  plots
%     factor_rtn_matrix(isnan(factor_rtn_matrix)) = 0;
%    
%     %market
%     mkt = factor_rtn_matrix(:,1);
%     b_m  = p.model.indexlev(datenum(p.model.indexlev.Properties.RowNames)>=p.model.model_trading_dates(1),:);
% 
%     c = [cumprod(1 + mkt),table2array(b_m)];
%     c(:,1)= c(:,1)/c(1,1)*1000;
%     c(:,2)= c(:,2)/c(1,2)*1000;
%     xlm = datenum(b_m.Properties.RowNames);
%    
%     fig = figure;
%     plot(xlm,c(:,1),xlm,c(:,2))
%     datetick('x','yy','keepticks')
%     legend('model','index');
%     title('market factor');
%     saveas(fig,[a.backtest,'\reggression\','mkt_factor.png']); 
%     fig.delete; clear fig;
%    
%     %styles
%     for i   = 1 : M
%         s = factor_rtn_matrix(:,strcmp(p.style(i),factor_rtns_matrix.Properties.VariableNames));
%         fig = figure;
%         plot(xlm,cumprod(1 + s));
%         datetick('x','yy','keepticks')
%         t  = p.style(i);
%         legend(t);
%         title(t);
%         saveas(fig,[a.backtest,'\reggression\',cell2mat(t),'.png']); 
%         fig.delete; clear fig;
%     end
%     
%     
%     %sectors
%     for i = 1 : S
%         se = factor_rtn_matrix(:,i+1);
%         fig = figure;
%         plot(xlm,cumprod(1 + se));
%         datetick('x','yy','keepticks')
%         t = factor_rtns_matrix.Properties.VariableNames(i+1);
%         legend(t);
%         title(t);
%         saveas(fig,[a.backtest,'\reggression\',cell2mat(t),'.png']); 
%         fig.delete; clear fig;
%     end
                   
end