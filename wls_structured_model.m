
function [mdl,tbl,factor_rtn,residuals,ERR] =  wls_structured_model(T_sector,T_style,pre_reg_y,T_stocks_cap_freecap_sector,T_weight_index,T_sus,r)
    ERR = [];
    rows = T_sector.Properties.RowNames;
    % 几个输入table的行变量名字必须一样（都为 市场代码(2) + 股票代码（6））
    chk = all(all([strcmp(rows,T_style.Properties.RowNames),strcmp(rows,pre_reg_y.Properties.RowNames),...
          strcmp(rows,T_stocks_cap_freecap_sector.Properties.RowNames),strcmp(rows,T_weight_index.Properties.RowNames),...
          strcmp(rows,T_sus.Properties.RowNames)]));
    if  chk
            % 算基准在各个行业上的权重
            s = T_sector.Properties.VariableNames;  len_s = length(s);
            u = zeros(len_s,1);
            for ii  = 1:len_s
                ind_code     = str2double(s{ii}(strfind(s{ii},'d')+1:end));
                idx_this_ind = T_stocks_cap_freecap_sector.sector == ind_code; % 该行业的股票
                idx_in_bhmk  = T_weight_index.w>0;                             % 是benchmark 的成分
                u(ii,1) = sum(T_weight_index.w(idx_this_ind&idx_in_bhmk))/100;
            end
     %      disp(['sum of exposures: ',num2str(sum(u))])
            u  = u/sum(u);
            [~ ,id]  = max(u);       id_ = (id==1:len_s); 

            w =  diag(sqrt(T_stocks_cap_freecap_sector.free_cap));  
            
            %  用自由流通市值最大的行业做分母： r_n = f_c + \sum_{i=1}^{I-1} (X_{ni} - \frac{\omega_i}{\omega_I} X_{nI})f_i  +... + \epsilon_n
            x0  = table2array(T_sector) - repmat(u'/u(id),size(T_sector,1),1).*repmat(table2array(T_sector(:,id)),1,size(T_sector,2));            
            x0(:,id_) = NaN; 
            x = [ones(size(x0,1),1),x0(:,~id_),table2array(T_style)];
           
            z = table2array(T_style);  z(isnan(z)) = 0; 
            T_style = array2table(z,'RowNames',T_style.Properties.RowNames,'VariableNames',T_style.Properties.VariableNames);
            
            x(isnan(x)) = 0; % 鉴于覆盖率还都比较高   
          
            % 回归
            in_the_index =  T_weight_index.w>0;  %基准成分
%             not_sus  = T_sus.if_sus == 0;        % 没停盘
%             id_tradeable = (pre_reg_y.y<0.105)&(pre_reg_y.y>-0.105); %涨幅不是过大 
            gamma_eq_one  = r.gamma ==1;
            id_in_reg  = in_the_index&gamma_eq_one; %实际参与回归的票

             w_ =  w(id_in_reg,id_in_reg) ;
             x_ =  x(id_in_reg,:);
             y_ =  pre_reg_y.y(id_in_reg,:);

            tbl = array2table([ mtimes(w_,y_),mtimes(w_,x_)],'RowNames',T_sector.Properties.RowNames(id_in_reg),...
                   'VariableNames', [{'y';'mkt'};T_sector.Properties.VariableNames(~id_)';T_style.Properties.VariableNames']);
            mdl   = fitlm(tbl,'ResponseVar','y','Intercept',false);
            f     = get_exp(T_sector,T_style, mdl,id,u); 
            % 有的时候报警告  Regression design matrix is rank deficient to within machine precision
            % 的原因是：基准里面有某个行业的票，但经过in_the_reg的筛除后，这个行业的票没了。因在tbl 中某个行业全是0。
            % 这个时候回归会自动将该行业当天的factor return 算成0 ，因此没必要在这里把这个行业去除掉了。
            factor_rtn = f ;
            f_  =  table2array(f)';
            res  = pre_reg_y.y - mtimes([ ones(height(T_sector),1),table2array(T_sector),table2array(T_style)],f_(~isnan(f_)));
            residuals =  array2table(res,'RowNames',T_sector.Properties.RowNames, 'VariableNames', {'Raw'});
    else
            error('please check your inputs')
    end
end