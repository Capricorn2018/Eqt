function soe_(p,a)
     T = length(p.all_trading_dates );
     N = length(p.stk_codes);
  
    load([a.input_data_path,'\DB\wind\soe.mat'],'t')
    % 国有企业:0805010000
    % (二级：中央国有企业:0805010100)
    % (二级：地方国有企业:0805010200)
    % 民营企业:0805020000
    % 外资企业:0805030000
    % (二级：中外合资企业:0805030100)
    % (二级：外商独资企业:0805030200)
    % 集体企业:0805040000
    % 公众企业:0805050000
    % 其他企业:0805060000

    soe = zeros(T,N);
    for  i = 1 : N
         info_this_stk = t(strcmp(p.stk_codes(i),t.S_INFO_WINDCODE),:); 
         info_this_stk = sortrows(info_this_stk,{'entrydt'},{'ascend'});
         ti = [info_this_stk.entrydt,info_this_stk.removedt];
         if ~isempty(ti)
            for j  = 1 : size(ti,1)

                if (ti(j,1)>0)&&(ti(j,2)>0)
                       idx1 = find(p.all_trading_dates>=ti(j,1),1,'first'); 
                       idx2 = find(p.all_trading_dates<=ti(j,2),1,'last'); 
                       k1 = strcmp(info_this_stk.WIND_SEC_CODE(j),'0805010000');
                       k2 = strcmp(info_this_stk.WIND_SEC_CODE(j),'0805010100');
                       k3 = strcmp(info_this_stk.WIND_SEC_CODE(j),'0805010200');
                       if k1||k2||k3
                          soe(idx1:idx2,i) = 1;
                       end
                end

                if (ti(j,1)>0)&&(ti(j,2)==0) 
                       idx1 = find(p.all_trading_dates>=ti(j,1),1,'first'); 
                       k1 = strcmp(info_this_stk.WIND_SEC_CODE(j),'0805010000');
                       k2 = strcmp(info_this_stk.WIND_SEC_CODE(j),'0805010100');
                       k3 = strcmp(info_this_stk.WIND_SEC_CODE(j),'0805010200');
                       if k1||k2||k3
                          soe(idx1:end,i) = 1;
                       end
                 end

                 if (ti(j,1)==0)&&(ti(j,2)==0)
                     warning(['Need to check ',cell2mat(p.stk_codes(i)),' ',num2str(1)]);
                 end

                 if (ti(j,1)==0)&&(ti(j,2)>0)
                       idx2 = find(p.all_trading_dates<=ti(j,2),1,'last'); 
                       k1 = strcmp(info_this_stk.WIND_SEC_CODE(j),'0805010000');
                       k2 = strcmp(info_this_stk.WIND_SEC_CODE(j),'0805010100');
                       k3 = strcmp(info_this_stk.WIND_SEC_CODE(j),'0805010200');
                       if k1||k2||k3
                          soe(1:idx2,i) = 1;
                       end
                 end

            end
         end
    end

        hdf5write([a.output_data_path,'\soe.h5'], 'date',p.all_trading_dates_, 'stk_code',p.stk_codes_, 'soe',soe);  


end