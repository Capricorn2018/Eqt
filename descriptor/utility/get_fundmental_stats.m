function get_fundmental_stats(p,a,q,d,K0,K1,K2,K3,K4,K5,K6,tgt)
     warning('off','stats:regress:RankDefDesignMat')
     q(q==0) = NaN;
     q(q==Inf) = NaN;
     q(q==-Inf) = NaN;
     f = {'q','q_d','q_yoy',...   %K0
         'q_vols','q_ts',... %K1
         'q_voll','q_tl',... %K2
         'q_last',... %K3
         'q_g','q_tg'...    %K4
         'q_greg','q_tgreg',...  % K5
         'q_quad','q_tquad'};    % K6
    
     for i = 2 : length(f)
        eval([f{i},'= NaN(size(q));']);
     end
     
     paras = table(f',{'K0','K0','K0','K1','K1','K2','K2','K3','K4','K4','K5','K5','K6','K6'}','VariableNames',{'f','para'});
     paras.K = zeros(height(paras),1);
     
     for i  = 1 : height(paras)
         eval(['paras.K(',num2str(i),',1)= ',cell2mat(paras.para(i)),';']);
     end
     
     %N = length(p.stk_codes);   

      if K0>0
          q_d   =  [NaN(K0,size(q,2)); q(K0+1:end,:)  - q(1:end-K0,:)]; %同比差额
          q_yoy =  [NaN(K0,size(q,2));(q(K0+1:end,:)  - q(1:end-K0,:))./abs(q(1:end-K0,:))]; % 同比增长
      end

      if K1>0
          for i  = K1: size(q,1)
              tmp1  = q(i-K1+1:i,:);
              q_vols(i,:) = std(tmp1,[],1); % 过去K1个季度的波动率 
              q_ts(i,:) = mean(tmp1,1)./q_vols(i,:); % 过去K1个季度的稳健增速：均值/波动率         
          end
      end
  
      if  K2>0 
          K2_ = K2/4;
          t_k2 = K2_-1:-1:0;
          for i  = K2-3: size(q,1)
              tmp1  = q(i-(t_k2)*4,:); % 过去K2_年同期值
             % disp(i-(t_k2)*4)
              q_voll(i,:) = std(tmp1,[],1); % 波动率 
              q_tl(i,:) = mean(tmp1,1)./q_voll(i,:); % 均值/波动率         
          end
      end

      if  K3>0 
         for i  = K3 : size(q,1)
              tmp1  = q(i-K3+1:i,:);
              %  disp(i-K3+1:i)
              q_last(i,:) = mean(tmp1,1); %长期均值
          end
      end
 
     if  K4>0 
         K4_ = K4/4;
         t_k4 = K4_:-1:0;
         for i  = K4+1: size(q,1)
              tmp1  = q(i-(t_k4)*4,:);
            %  disp(i-(t_k4)*4)
              q_g(i,:)  = 2*tmp1(2,:) - tmp1(1,:) - tmp1(end,:);%二阶差分：　加速度
              q_tg(i,:) =- q_g(i,:)./mean(tmp1,1);%二阶差分：　加速度/均值
         end
      end

      if  K5>0 
           for i  = K5 : size(q,1)
              tmp1  = q(i-K5+1:i,:);
              for j  = 1:size(tmp1,2)
                  if  ~any(isnan(tmp1(:,j)))
                      b  = regress(tmp1(:,j),[ones(K5,1),(1:K5)']);
                      q_greg(i,j) = b(2); % 趋势（有量纲）
                      b  = regress(tmp1(:,j)/mean(tmp1(:,j)),[ones(K5,1),(1:K5)']);
                      if strcmp(lastwarn,'X is rank deficient to within machine precision.')
                           disp(['K5(2): i= ',num2str(i),' j = ',num2str(j)]);
                           lastwarn('')
                      end
                      q_tgreg(i,j) = b(2); % 趋势（无量纲）
                  end
              end
           end
      end

  
      if  K6>0 
           for i  = K6 : size(q,1)
              tmp1  = q(i-K6+1:i,:);
              for j  = 1:size(tmp1,2)
                  if  ~any(isnan(tmp1(:,j)))
                      b  = regress(tmp1(:,j),[ones(K6,1),(1:K6)',(1:K6)'.*(1:K6)']);
                      q_quad(i,j) = b(3);
                      
                      b  = regress(tmp1(:,j)/mean(tmp1(:,j)),[ones(K6,1),(1:K6)',(1:K6)'.*(1:K6)']);
                      if strcmp(lastwarn,'X is rank deficient to within machine precision.')
                           disp(['K6(2): i= ',num2str(i),' j = ',num2str(j)]);
                           lastwarn('')
                      end
                      q_tquad(i,j) = b(3);
                  end
              end
           end
      end

       for i = 1 : length(f)
            eval([f{i},' = expand_single_value(',f{i},',d,p);']);
            tgt_file = [ a.output_data_path ,'\',tgt,'_',cell2mat(paras.f(i)),'-',num2str(paras.K(i)),'.h5'];
            if  exist(tgt_file,'file')==2, eval(['delete ',tgt_file]);  end
            tgt_tag  = cell2mat(paras.f(i));
            word = ['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');'];
            eval(['if ',cell2mat(paras.para(i)),'>0,',word,'end;']);
       end
    
end