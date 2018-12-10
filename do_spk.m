function do_spk(p,a,K1,K2)


     N = length(p.model.stk_codes);
     T = length(p.model.model_trading_dates);
     S = height(p.model.ind_names);
     M = length(p.style.style);    
     D = max([p.spk.spk_N ,p.spk.nw_N,p.spk.vra_N]);
     

  for  idx_index = K1:K2     
%        idx = find(p.model.model_trading_dates(1) == p.model.all_trading_dates);
%        index_membs  =  p.model.indexmemb.(['index',num2str(idx_index)]); %　基准成分    
%        index_membs_n   = table2array(index_membs);
%        dates_in_index = datenum(index_membs.Properties.RowNames);
%        idx_bcmk = find(p.model.model_trading_dates(1) == dates_in_index);
       
        %  －－－－－－－－－－ load 历史上每一天的 specific return（可能有空值就用NAN表示），存储在 res_rtn_matrix 里面  －－－－－－－－－－
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
           
        %  －－－－－－－－－－ 计算每一天的 sigma_SH 和 B^s  －－－－－－－－－－  
        residuals_last_day  = [];
        for i = (D+1) : T       % i=5000 % 为何有的市值为0？
              x = exist([a.spk,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],'file');
              if x==2
                  load ([a.spk,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],  'residuals');   
              else
                  idx_dt = find(p.model.all_trading_dates(i)==p.model.all_trading_dates,1,'first');   
                  r_rtn   = res_rtn_matrix((idx_dt-p.spk.spk_N)  :idx_dt,  idx_res_rtn_matrix(idx_dt,:)==1);  
                  nw_rtn  = res_rtn_matrix((idx_dt-p.spk.nw_N)   :idx_dt,  idx_res_rtn_matrix(idx_dt,:)==1);  
                  h_rtn   = res_rtn_matrix((idx_dt-p.spk.h)      :idx_dt,  idx_res_rtn_matrix(idx_dt,:)==1);  
                  y   =   exist([a.reggression,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],'file');
                  if  (y==2)&&any(all(~isnan(r_rtn),1))&&any(all(~isnan(nw_rtn),1))&&any(all(~isnan(h_rtn),1))
                      load ([a.reggression,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],...
                             'residuals','mdl','T_sector','T_style','T_stocks_cap_freecap_sector','T_weight_index','T_sus'); 
                   
                      % －－－－－－－－－－ nw -adj  －－－－－－－－－－－－－－－
                      [residuals.nw,residuals.ewma] = nw_adj_spk(r_rtn,nw_rtn,p);
                      residuals.nw = sqrt(residuals.nw);
                      residuals.ewma = sqrt(residuals.ewma);
                      
                      %  －－－－－－－－－－ structured model  －－－－－－－－－－
                       [residuals.gamma] = deal(NaN(height(residuals),1));
                       for j = 1 : height(residuals)
                            x = h_rtn(:,j); x = x(~isnan(x));
                            su = (1/1.35)*(quantile(x,0.75)-quantile(x,0.25));
                            zu = abs(std(x)/su - 1);
                            residuals.gamma(j,1) = min(1,max(0,(length(x)-60)/120))*min(1,max(0,exp(1-zu)));
                       end
                       tmp = residuals(:,'nw'); tmp.Properties.VariableNames = {'y'}; tmp.y = log(tmp.y);
                      T_sector = replace_nan_to_z(T_sector,0);
                      T_style  = replace_nan_to_z(T_style,0);
                      [~,~,b,~,~] =  wls_structured_model(T_sector,T_style,tmp,T_stocks_cap_freecap_sector,T_weight_index,T_sus,residuals);                  
                      residuals.str = p.spk.E0*exp(mtimes( [ones(height(T_sector),1),table2array(T_sector),table2array(T_style)],table2array(b)'));
                      residuals.structured  = residuals.gamma.*residuals.nw + (1-residuals.gamma).*residuals.str;
                      
                      % －－－－－－－－－－ Bayesian Shrinkage －－－－－－－－－－
                      % 1按照市值分组
                      [residuals.grp,residuals.sigmasn,residuals.deltasn,residuals.vn,residuals.sh] = deal(NaN(height(residuals),1));
                      T_stocks_cap_freecap_sector  = replace_nan_to_z(T_stocks_cap_freecap_sector,0);
                      T_stocks_cap_freecap_sector.order  = (1:height(T_stocks_cap_freecap_sector))';
                      size_q  = sortrows(T_stocks_cap_freecap_sector,'free_cap');
                      each_grp_num = round(height(residuals)/10);
                      for j = 1 : p.spk.groups-1
                          stks_this_grp = size_q.order((j-1)*each_grp_num+1:j*each_grp_num);
                          residuals.grp(stks_this_grp) = j;
                      end
                      residuals.grp(isnan(residuals.grp)) = p.spk.groups;
                      for j = 1: p.spk.groups
                          idx_this_grp =  residuals.grp == j;
                          s = residuals.structured(idx_this_grp);   
                          w = T_stocks_cap_freecap_sector.free_cap(idx_this_grp);
                          residuals.sigmasn(idx_this_grp)= sum(s.*w)/sum(w);  % 2. 算sigma(sn) 
                          residuals.deltasn(idx_this_grp) = std(s);  %  3. 算delta(sn)
                      end
                      tmp_diff =  p.spk.k*abs(residuals.structured-residuals.sigmasn);
                      residuals.vn = tmp_diff./(residuals.deltasn + tmp_diff); %4. 算vn 
                      residuals.sh  = residuals.vn.*residuals.sigmasn  +(1- residuals.vn).*residuals.structured;
                  else
                      residuals = [];
                  end
                  
                  save ([a.spk,'\','Index',num2str(idx_index),'_',datestr(p.model.all_trading_dates(i),29),'.mat'],  'residuals');
              end  % end for  if x==2
              residuals_last_day  = residuals; clear residuals;
       end  % end for i = 1 : T
       
  end    % end for for  idx_index = K1:K2 
     
end