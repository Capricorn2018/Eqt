     N = length(p.model.stk_codes);
     T = length(p.model.model_trading_dates);
     S = height(p.model.ind_names);
     M = length(p.style.style);  
      
     data_mktcap     = h5read(p.file.totalshrs,   '/total_capital')'/1e4;  % #dates by #stocks
     data_freecap    = h5read(p.file.freeshrs,    '/free_cap')'/1e4;       % #dates by #stocks

     data_satus      =  h5read(p.file.status,'/stk_status')';          % if(ST<>PT<>暂停上市<>该日期<该股票上市日<>该日期>该股票退市日,0,1)
     data_satus(isnan(data_satus)) = 0;
     data_satus = logical(data_satus);
     
     data_sus        =  h5read(p.file.sus,'/is_suspended')';           % if(停盘，1,0）
     data_sus(isnan(data_sus)) = 0;
     data_sus = logical(data_sus);

     data_sector_lv3     =  h5read(p.file.ind,'/citics_stk_sectors_3')'; 
     
     data_sector         =  NaN(size(data_sector_lv3));
     for i = 1 : S    % 找到每个股票的三级行业，对应于p.model.ind_names（行业分类的标准）中的一级行业，结果用data_sector来装载
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
         index_membs  =  p.model.indexmemb.(['index',num2str(idx_index)]); %　基准成分    
         index_membs_n   = table2array(index_membs);
         for i = 1 : T
             % （原始的）所有股票的市值，自由流通市值，行业
             stocks_cap_freecap_sector = [data_mktcap(idx-1,:)',data_freecap(idx-1,:)',data_sector(idx-1,:)']; % 今天存储的是昨天EOD的市值。
             T_stocks_cap_freecap_sector = array2table(stocks_cap_freecap_sector,'RowNames',p.model.stk_codes1,'VariableNames',{'total_cap','free_cap','sector'});
             

             %　－－－－－－－－－－－筛选coverage universe股票　－－－－－－－－－－－－           
             % data_satus = 1和有行业的
             idx_stk1    =  data_satus(idx,:) == 1;   % 该天status=1的
             idx_stk2    =  data_satus(idx-1,:) == 1; % 昨天status=1的
             idx_stk3    =  data_sector(idx,:)>0;     % 今天有行业
             idx_stk4    =  data_sector(idx-1,:)>0;   % 昨天有行业        
             idx_stk     = (idx_stk1&idx_stk2&idx_stk3&idx_stk4)';

             % 没有市值的     
             idx_no_mkt_cap1  = isnan(data_mktcap(idx,:));
             idx_no_mkt_cap2  = isnan(data_mktcap(idx-1,:));
             idx_no_mkt_cap = (idx_stk&idx_no_mkt_cap1'&idx_no_mkt_cap2');

             % 没有自由流通市值的
             idx_no_freecap1  = isnan(data_freecap(idx,:));
             idx_no_freecap2  = isnan(data_freecap(idx-1,:));
             idx_no_freecap = (idx_stk&idx_no_freecap1'&idx_no_freecap2');    

             idx_left =idx_no_mkt_cap|idx_no_freecap;
             
             % 该日，基准所有股票中如果没有和这个股票的行业相同，那么这个股票的状态设置为0
             est_universe = index_membs_n(max(i-1,1),:)'; % 上一个交易日所有股票在estimation 里面的权重
             est_universe_sector_number  = data_sector(idx-1,:)';
             est_universe_sector_num     = sort(unique(est_universe_sector_number(est_universe>0)));
             idx_sector_in_est_universe  = ismember(est_universe_sector_number,est_universe_sector_num);
           
             % coverage universe 里面的所有票 idx_pre_reg 值为1
             idx_pre_reg = (~idx_left)&idx_sector_in_est_universe;
             
             
              %　－－－－－－－－－－－行业因子　－－－－－－－－－－－－    
             N1 = sum(idx_pre_reg); %coverage universe 的股票数目
             S1 = length(est_universe_sector_num); % coverage universe 和estimation universe 中的行业数目（两者相等）
             
             table_stctor_today = zeros(N,S1);
             
             for j  = 1 : S1
                 idxx  = est_universe_sector_number == est_universe_sector_num(j) ;
                 table_stctor_today(idxx',j) = 1;
             end
             
             table_stctor_today = table_stctor_today(idx_pre_reg,:); % coverage universe里面的行业因子信息
             
             T_sector = array2table(table_stctor_today,'RowNames',p.model.stk_codes1(idx_pre_reg),'VariableNames',p.model.ind_names.Eng(est_universe_sector_num)');
             
             %　－－－－－－－－－－－风格因子　－－－－－－－－－－－－    
             T = T_sector;  T(:,1:end) = [];
             [T_des,T_style] = deal(T);
             
             % 仅仅用benchmark 的成分来计算zscore
             % est_universe: 上一个交易日所有股票在estimation 里面的权重
             weight_vector = est_universe(idx_pre_reg);  % 如果指数存在停盘，这里可以不是100
  

             for j = 1 : M
                if ~strcmp(p.style.style(j),'soe')
                    descriptors = p.style.sty.descriptors_(strcmp(p.style.sty.factors,p.style.style(j)));
                    wei         = p.style.sty.weight(strcmp(p.style.sty.factors,p.style.style(j)));
                    z = zeros(height(T_des),1);
                    for k = 1 : length(wei)
                        eval(['T_des.(cell2mat(descriptors(k))) =' cell2mat(descriptors(k)),'(idx-1,idx_pre_reg)'';']);% 取数，取的是昨天的exposure
                        z = z + wei(k)*cal_zscore(T_des.(cell2mat(descriptors(k))),weight_vector);  % cal zscore
                    end
                    T_style.(cell2mat(p.style.style(j))) = cal_zscore(z,weight_vector);
                end
             end

             if any(ismember(p.style.style,'soe'))
                %  p.styles01  可以用到这里自动弄，鉴于现在这样的变量只有SOE一个，先凑合了
                T_des.soe  = soe(idx-1,idx_pre_reg)';
                T_style.soe  = soe(idx-1,idx_pre_reg)';
             end
             %%
               stocks_cap_freecap_sector = [data_mktcap(idx-1,:)',data_freecap(idx-1,:)',data_sector(idx-1,:)']; % 今天存储的是昨天EOD的市值。
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