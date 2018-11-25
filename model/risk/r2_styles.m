function  r2_styles(p,a,K1,K2)

     N = length(p.model.stk_codes);
     T = length(p.model.model_trading_dates);
     M = length(p.style.style);  % number of styles
%% 

     
    for j  = 1 : height(p.style.sty)
       file_name  =  p.file.(cell2mat(p.style.sty.descriptors_(j)));
       tag_name   = get_tag(file_name);
       eval([cell2mat(p.style.sty.descriptors_(j)),' = h5read(''',file_name,'', ''',''/',tag_name,''');']);
    end
    clear j;
    
    for  idx_index = K1:K2
      
        idx = find(p.model.model_trading_dates(1)==p.model.all_trading_dates);      
        index_w = zeros(T,1);

        index_membs  =  p.model.indexmemb.(['index',num2str(idx_index)]); %����׼�ɷ�    
        index_membs_n   = table2array(index_membs);

        for i = 1 :T 
             load ([a.sector,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],'T_sector_today','T_stocks_cap_freecap_sector','T_sectors_cap_freecap','T_sus');             
             idx_stk = ismember(p.model.stk_codes1',T_sector_today.Properties.RowNames);      % ����Ĺ�Ʊ������ͣ�̵�                            
                   
             [T_des,T_sector_style] = deal(T_sector_today);
           
             % �����й�Ʊ�в���benchmark �ɷֵĳ�ȥ��������benchmark �ĳɷ�������zscore
             indexw  =  index_membs_n(max(i-1,1),:);      % �����ָ��Ȩ��
             weight_vector = indexw(idx_stk)';  % ���ָ������ͣ�̣�������Բ���100
             index_w(i,1) = sum(weight_vector);

             for j = 1 : M
                if ~strcmp(p.style.style(j),'soe')
                    descriptors = p.style.sty.descriptors_(strcmp(p.style.sty.factors,p.style.style(j)));
                    wei         = p.style.sty.weight(strcmp(p.style.sty.factors,p.style.style(j)));
                    z = zeros(height(T_des),1);
                    for k = 1 : length(wei)
                        eval(['T_des.(cell2mat(descriptors(k))) =' cell2mat(descriptors(k)),'(idx-1,idx_stk)'';']);% ȡ����ȡ���������exposure
                        z = z + wei(k)*cal_zscore(T_des.(cell2mat(descriptors(k))),weight_vector);  % cal zscore
                    end
                   T_sector_style.(cell2mat(p.style.style(j))) = cal_zscore(z,weight_vector);
                end
             end

             if any(ismember(p.style.style,'soe'))
                %  p.styles01  �����õ������Զ�Ū���������������ı���ֻ��SOEһ�����ȴպ���
                T_des.soe  = soe(idx-1,idx_stk)';
                T_sector_style.soe  = soe(idx-1,idx_stk)';
             end
 
             save ([a.style,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],'T_sector_style','T_des'); 
            
             if i<T,idx = idx+1;end;
        end
        
    end  %end for  for  idx_index = K1:K2
end