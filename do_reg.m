     N = length(p.model.stk_codes);
     T = length(p.model.model_trading_dates);
     S = height(p.model.ind_names);
     M = length(p.style.style);  
      
     data_mktcap     = h5read(p.file.totalshrs,   '/total_capital')'/1e4;  % #dates by #stocks
     data_freecap    = h5read(p.file.freeshrs,    '/free_cap')'/1e4;       % #dates by #stocks

     data_satus      =  h5read(p.file.status,'/stk_status')';          % if(ST<>PT<>��ͣ����<>������<�ù�Ʊ������<>������>�ù�Ʊ������,0,1)
     data_satus(isnan(data_satus)) = 0;
     data_satus = logical(data_satus);
     
     data_sus        =  h5read(p.file.sus,'/is_suspended')';           % if(ͣ�̣�1,0��
     data_sus(isnan(data_sus)) = 0;
     data_sus = logical(data_sus);

     data_sector_lv3     =  h5read(p.file.ind,'/citics_stk_sectors_3')'; 
     
     data_sector         =  NaN(size(data_sector_lv3));
     for i = 1 : S    % �ҵ�ÿ����Ʊ��������ҵ����Ӧ��p.model.ind_names����ҵ����ı�׼���е�һ����ҵ�������data_sector��װ��
         sub_codes  = p.model.ind_subcode.(cell2mat(p.model.ind_names.Eng(i)));
         for j  = 1 : length(sub_codes)
             id_sub_codes = sub_codes(j) == data_sector_lv3;
             data_sector(id_sub_codes) = i;  
          end
     end  
     
     for j  = 1 : height(p.style.sty)
       file_name  =  p.file.(cell2mat(p.style.sty.descriptors_(j)));
       tag_name   = get_tag(file_name);
       eval([cell2mat(p.style.sty.descriptors_(j)),' = h5read(''',file_name,'', ''',''/',tag_name,''');']);
    end
    clear j; 
     
     
     %  idx_index = 1;
     for  idx_index = K1:K2
         idx = find(p.model.model_trading_dates(1) == p.model.all_trading_dates);
         index_membs  =  p.model.indexmemb.(['index',num2str(idx_index)]); %����׼�ɷ�    
         index_membs_n   = table2array(index_membs);
         for i = 1 : T
             % ��ԭʼ�ģ����й�Ʊ����ֵ��������ͨ��ֵ����ҵ
             stocks_cap_freecap_sector = [data_mktcap(idx-1,:)',data_freecap(idx-1,:)',data_sector(idx-1,:)']; % ����洢��������EOD����ֵ��
             T_stocks_cap_freecap_sector = array2table(stocks_cap_freecap_sector,'RowNames',p.model.stk_codes1,'VariableNames',{'total_cap','free_cap','sector'});
             

             %������������������������ɸѡcoverage universe��Ʊ��������������������������           
             % data_satus = 1������ҵ��
             idx_stk1    =  data_satus(idx,:) == 1;   % ����status=1��
             idx_stk2    =  data_satus(idx-1,:) == 1; % ����status=1��
             idx_stk3    =  data_sector(idx,:)>0;     % ��������ҵ
             idx_stk4    =  data_sector(idx-1,:)>0;   % ��������ҵ        
             idx_stk     = (idx_stk1&idx_stk2&idx_stk3&idx_stk4)';

             % û����ֵ��     
             idx_no_mkt_cap1  = isnan(data_mktcap(idx,:));
             idx_no_mkt_cap2  = isnan(data_mktcap(idx-1,:));
             idx_no_mkt_cap = (idx_stk&idx_no_mkt_cap1'&idx_no_mkt_cap2');

             % û��������ͨ��ֵ��
             idx_no_freecap1  = isnan(data_freecap(idx,:));
             idx_no_freecap2  = isnan(data_freecap(idx-1,:));
             idx_no_freecap = (idx_stk&idx_no_freecap1'&idx_no_freecap2');    

             idx_left =idx_no_mkt_cap|idx_no_freecap;
             
             % ���գ���׼���й�Ʊ�����û�к������Ʊ����ҵ��ͬ����ô�����Ʊ��״̬����Ϊ0
             est_universe = index_membs_n(max(i-1,1),:)'; % ��һ�����������й�Ʊ��estimation �����Ȩ��
             est_universe_sector_number  = data_sector(idx-1,:)';
             est_universe_sector_num     = sort(unique(est_universe_sector_number(est_universe>0)));
             idx_sector_in_est_universe  = ismember(est_universe_sector_number,est_universe_sector_num);
           
             % coverage universe ���������Ʊ idx_pre_reg ֵΪ1
             idx_pre_reg = (~idx_left)&idx_sector_in_est_universe;
             
             
              %��������������������������ҵ���ӡ�������������������������    
             N1 = sum(idx_pre_reg); %coverage universe �Ĺ�Ʊ��Ŀ
             S1 = length(est_universe_sector_num); % coverage universe ��estimation universe �е���ҵ��Ŀ��������ȣ�
             
             table_stctor_today = zeros(N,S1);
             
             for j  = 1 : S1
                 idxx  = est_universe_sector_number == est_universe_sector_num(j) ;
                 table_stctor_today(idxx',j) = 1;
             end
             
             table_stctor_today = table_stctor_today(idx_pre_reg,:); % coverage universe�������ҵ������Ϣ
             
             T_sector = array2table(table_stctor_today,'RowNames',p.model.stk_codes1(idx_pre_reg),'VariableNames',p.model.ind_names.Eng(est_universe_sector_num)');
             
             %������������������������������ӡ�������������������������    
             T = T_sector;  T(:,1:end) = [];
             [T_des,T_style] = deal(T);
             
             % ������benchmark �ĳɷ�������zscore
             % est_universe: ��һ�����������й�Ʊ��estimation �����Ȩ��
             weight_vector = est_universe(idx_pre_reg);  % ���ָ������ͣ�̣�������Բ���100
  

             for j = 1 : M
                if ~strcmp(p.style.style(j),'soe')
                    descriptors = p.style.sty.descriptors_(strcmp(p.style.sty.factors,p.style.style(j)));
                    wei         = p.style.sty.weight(strcmp(p.style.sty.factors,p.style.style(j)));
                    z = zeros(height(T_des),1);
                    for k = 1 : length(wei)
                        eval(['T_des.(cell2mat(descriptors(k))) =' cell2mat(descriptors(k)),'(idx-1,idx_pre_reg)'';']);% ȡ����ȡ���������exposure
                        z = z + wei(k)*cal_zscore(T_des.(cell2mat(descriptors(k))),weight_vector);  % cal zscore
                    end
                    T_style.(cell2mat(p.style.style(j))) = cal_zscore(z,weight_vector);
                end
             end

             if any(ismember(p.style.style,'soe'))
                %  p.styles01  �����õ������Զ�Ū���������������ı���ֻ��SOEһ�����ȴպ���
                T_des.soe  = soe(idx-1,idx_pre_reg)';
                T_style.soe  = soe(idx-1,idx_pre_reg)';
             end
             %%
               stocks_cap_freecap_sector = [data_mktcap(idx-1,:)',data_freecap(idx-1,:)',data_sector(idx-1,:)']; % ����洢��������EOD����ֵ��
               T_stocks_cap_freecap_sector = array2table(stocks_cap_freecap_sector,'RowNames',p.model.stk_codes1,'VariableNames',{'total_cap','free_cap','sector'});
               T_stocks_cap_freecap_sector(~x,:) = [];

               [G,R] = findgroups(T_stocks_cap_freecap_sector.sector);
               sum_free_cap_   =  array2table([R,splitapply(@sum,T_stocks_cap_freecap_sector.free_cap,G)], 'VariableNames',{'sector','free_cap'});
               sum_total_cap_  =  array2table([R,splitapply(@sum,T_stocks_cap_freecap_sector.total_cap,G)],'VariableNames',{'sector','total_cap'});
               T_sectors_cap_freecap = outerjoin(sum_free_cap_,sum_total_cap_,'Type','left','MergeKeys',true);
               T_sectors_cap_freecap.weight_freecap   = T_sectors_cap_freecap.free_cap/nansum(T_sectors_cap_freecap.free_cap);
               T_sectors_cap_freecap.weight_total_cap = T_sectors_cap_freecap.total_cap/nansum(T_sectors_cap_freecap.total_cap);


               idxxx = ismember(p.model.stk_codes,stks_today);

               T_sus   = array2table(  data_sus(idx,idxxx)','RowNames',p.model.stk_codes1(idxxx),'VariableNames',{'if_sus'});            
               
               T_sector_today = array2table(table_stctor_today,'RowNames',p.model.stk_codes1(idxxx),'VariableNames',sectors.Eng');
               save ([a.sector,'\',['Index',num2str(idx_index)],'_',datestr(p.model.model_trading_dates(i),29),'.mat'],...
                                                            'T_sector_today','T_stocks_cap_freecap_sector','T_sectors_cap_freecap','T_sus');

               if i<T,idx = idx+1;end;
         end  % end for  i = 1 : T
     end  % end for idx_index = 0 :  length(fieldnames(p.model.alpha_code))-1 
 end