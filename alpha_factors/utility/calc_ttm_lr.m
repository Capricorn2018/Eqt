% ע�⣡���е�code��Ĭ�ϴ������ı����¼�ǰ���
% s_info_windcode, report_period desc, actual_ann_dt desc �������

function calc_ttm_lr(input_folder, db_names, output_folder, rpt_type)
% ���±�������LR, SQ, LYR, TTM, YOY, LTG��
% ��ÿ���pit_data�н�ȡ�����ֶΣ����ڵ������ļ���
% db_names�����ݿ��ֶ���, ����AShareIncome�����net_profit_excl_min_int_inc
% input_folder = 'D:/Projects/pit_data/mat/income'; �Ǵ��pit_data��λ��
% stk_codes����wind�������s_info_windcode
% output_folder = 'D:/Projects_pit_data/mat/alpha_factors'; ��������Ž���ĵ�ַ
% rpt_type = 'LYR' �����걨����
% rpt_type = 'SQ' ���±���������
% rpt_type = 'LR' ���¼�(��)������

    % input_folder�Ǵ��pit_data��λ��
    files = dir(input_folder); % ȡ���ļ��б�    
    
    % ѭ��ȡ���ļ����Լ��Ƿ����ļ��еı�־isdir
    filename = cell(length(files),1);
    isdir = zeros(length(files),1);
    for i=1:length(files)
        filename{i} = files(i).name;
        isdir(i) = files(i).isdir;
    end
    
    % ȥ�����е��ļ���
    filename = filename(isdir==0);
    T = length(filename);  % �ļ�����    
    
    % dt���������ļ����н�ȡ�����ַ���������
    dt = cell(length(filename),1);
    ndt = nan(length(filename),1);
    for i=1:T
        dt{i} = file2dt(filename{i}); % ���ļ�����ȡ�����ַ���
        ndt(i) = datenum(dt{i},'yyyymmdd');
    end
    
    % ��¼ÿ���ֶ���Ҫ���µ���ʼ��
    S = zeros(length(db_names),1);
    
    % ��ʼ�����
    % result = nan(length(filename),length(stk_codes));
    tgt_file = cell(length(db_names),1);
    for i=1:length(db_names)
%         eval([db_names{i},' = nan(length(filename),length(stk_codes));']);
%         eval([db_names{i},' = array2table(',db_names{i},',''VariableNames'',colnames);']);
        tgt_file{i} = [output_folder,'/',rpt_type,'_',db_names{i},'.mat'];
%         eval(['[S(',int2str(i),'),',db_names{i},'] = check_exist(''',tgt_file{i},''',''/',db_names{i},''',p,T,N);']);
        if ~exist(tgt_file{i},'file')==2
            x = load(tgt_file{i}); %#ok<NASGU>
            x_date = eval(['x.',db_names{i},'.date;']);
            x_date = yyyy2datenum(x_date);
            S(i) = find(ndt>max(x_date),1);
            if isempty(S(i)) 
                S(i)=0;
            end
            eval([db_names{i},'=x.',db_names{i},';']);
        else
            S(i) = 1;
            eval([db_names{i},'=table();']);
        end
    end
    
    Smin = min(S(S>0));
    
    if(max(S)==0)
        disp('cal_ttm_lr.m: no need to update.');
        return;
    end
    
    % ѭ����pit�����н�ȡ���µ��걨��������Ҫ���ֶ�
    for i = Smin:T
        
        x = load([input_folder,'/',filename{i}]); % ��ȡ���յ�pit_data
        fn = fieldnames(x);
        if ~isempty(find(strcmp(fn,'data_last'),1))
            data_last = x.data_last(:,[db_names,'rank_rpt','s_info_windcode']);
            data_last.date = cellstr(repmat(dt{i},height(data_last),1));
        else
            if ~isempty(find(strcmp(fn,'cap'),1))
                data_last = x.cap(:,[db_names,'rank_rpt','s_info_windcode']);
                data_last.date = cellstr(repmat(dt{i},height(data_last),1));
            end
            if ~isempty(find(strcmp(fn,'price'),1))
                data_last = x.price(:,[db_names,'rank_rpt','s_info_windcode']);
                data_last.date = cellstr(repmat(dt{i},height(data_last),1));
            end
        end
        if ~isempty(find(strcmp(fn,'single'),1))
            single = x.single(:,[db_names,'rank_rpt','s_info_windcode']);
            single.date = cellstr(repmat(dt{i},height(single),1));
        end
        
        
        switch rpt_type
            case 'LYR'
                
                % ɸѡ�����걨
                result = data_last(data_last.season==4,:); 

                % ���еĴ���
                code = result.s_info_windcode;
                code = unique(code);

                % Ϊ��ֹdata�������ͬһ��Ʊ������������¼��״��
                % ÿ����Ʊֻѡ���������¼
                [~,Locb] = ismember(code,result.s_info_windcode);
                result = result(Locb,:); %#ok<NASGU>
            
            case 'SQ'
                
                % ɸѡ���µĵ�������
                result = single(single.rank_rpt==1,:);  

                % ���еĴ���
                code = result.s_info_windcode;
                code = unique(code);
                
                % Ϊ��ֹdata�������ͬһ��Ʊ������������¼��״��
                % ÿ����Ʊֻѡ���������¼
                [~,Locb] = ismember(code,result.s_info_windcode);
                result = result(Locb,:); %#ok<NASGU>
                
             case 'LR'
                 
                % ɸѡ���µļ�������
                result = data_last(data_last.rank_rpt==1,:);

                % ���еĴ���
                code = result.s_info_windcode;
                code = unique(code);

                % Ϊ��ֹdata�������ͬһ��Ʊ������������¼��״��
                % ÿ����Ʊֻѡ���������¼
                [~,Locb] = ismember(code,result.s_info_windcode);
                result = result(Locb,:); %#ok<NASGU>
                
            case 'TTM'
                
                 % ѡ���µ�4�ڵ�������
                data = single(single.rank_rpt<=4,:); 

                % ���еĴ���
                code = data.s_info_windcode;
                code = unique(code);

                % ������ĸ����ȶ�Ӧ�ĵ�������
                s1 = data(data.rank_rpt==1,:);
                s2 = data(data.rank_rpt==2,:);
                s3 = data(data.rank_rpt==3,:);
                s4 = data(data.rank_rpt==4,:);

                % ��ʼ�����
                result = nan(size(code,1),size(data,2));
                result = array2table(result,'VariableNames',data.Properties.VariableNames);

                % �����µ��ĸ����ȶ�Ӧ���ֶ���Ӽ���ttm
                % ��������ͬһ��(��)����ͬһactual_ann_dt�ж�����¼���������ֻ�õ�����������
                [Lia,Locb] = ismember(code,s1.s_info_windcode);
                result(Lia,db_names) = s1(Locb(Locb>0),db_names);
                season1 = nan(size(result,1),1);
                season1(Lia) = s1.report_period(Locb(Locb>0));

                [Lia2,Locb2] = ismember(code,s2.s_info_windcode);
                add = array2table(nan(size(result)),'VariableNames',result.Properties.VariableNames);
                add(Lia2,db_names) = s2(Locb2(Locb2>0),db_names);
                result(:,db_names) = array2table(table2array(result(:,db_names)) + table2array(add(:,db_names)));

                [Lia3,Locb3] = ismember(code,s3.s_info_windcode);
                add = array2table(nan(size(result)),'VariableNames',result.Properties.VariableNames);
                add(Lia3,db_names) = s3(Locb3(Locb3>0),db_names);
                result(:,db_names) = array2table(table2array(result(:,db_names)) + table2array(add(:,db_names)));

                [Lia4,Locb4] = ismember(code,s4.s_info_windcode);
                add = array2table(nan(size(result)),'VariableNames',result.Properties.VariableNames);
                add(Lia4,db_names) = s4(Locb4(Locb4>0),db_names);
                result(:,db_names) = array2table(table2array(result(:,db_names)) + table2array(add(:,db_names)));
                season4 = nan(size(result,1),1);
                season4(Lia4) = s4.report_period(Locb4(Locb4>0));

                % ���s4��Ӧ��season�ǲ�������������ǰ
                l4s = nan(size(result,1),1);
                l4s(Lia) = lastNseason(season1(Lia),3);
                result(season4~=l4s,:) = array2table(nan(size(result(season4~=l4s,:)))); %#ok<NASGU>
                
            case 'YOY'
                                
                % ѡ���µ�4�ڵ�������
                data = single(single.rank_rpt==1 | single.rank_rpt==5,:);

                % ���еĴ���
                code = data.s_info_windcode;
                code = unique(code);

                % ������ĸ����ȶ�Ӧ�ĵ�������
                s1 = data(data.rank_rpt==1,:);
                s5 = data(data.rank_rpt==5,:);
                                
                % ��ʼ�����
                result = nan(size(code,1),size(data,2));
                result = array2table(result,'VariableNames',data.Properties.VariableNames);

                % �����µ��ĸ����ȶ�Ӧ���ֶ���Ӽ���ttm
                % ��������ͬһ��(��)����ͬһactual_ann_dt�ж�����¼���������ֻ�õ�����������
                [Lia,Locb] = ismember(code,s1.s_info_windcode);
                result(Lia,db_names) = s1(Locb(Locb>0),db_names);
                season1 = nan(size(result,1),1);
                season1(Lia) = s1.report_period(Locb(Locb>0));

                [Lia5,Locb5] = ismember(code,s5.s_info_windcode);
                div = array2table(nan(size(result)),'VariableNames',result.Properties.VariableNames);
                tmp_s5 = table2array(s5(Locb5(Locb5>0),db_names));
                tmp_s5(tmp_s5<0) = NaN; % ��ĸΪ����ֵ����Ҫ��ΪNaN�Ա�������YoY����
                div(Lia5,db_names) = array2table(tmp_s5);
                result(:,db_names) = array2table(table2array(result(:,db_names)) ./ table2array(div(:,db_names)) - 1);
                season5 = nan(size(result,1),1);
                season5(Lia5) = s5.report_period(Locb5(Locb5>0));

                % ���s5��Ӧ��season�ǲ���һ����ǰ
                l5s = nan(size(result,1),1);
                l5s(Lia) = lastNseason(season1(Lia),4); % 4������֮ǰ����ȥ����ͬ����
                result(season5~=l5s,:) = array2table(nan(size(result(season5~=l5s,:)))); %#ok<NASGU>
                
            case 'LTG'                  
                                
                % ѡ���µ�12�ڵ�������
                data = single(single.rank_rpt<=12,:);                 
                
                % ��dataû�������, ������
                if(~issorted(data.s_info_windcode))
                    data = sortrows(data,{'s_info_windcode','rank_rpt','rank_ann'},{'ascend','ascend','ascend'});                                        
                end
                
                % ���еĴ���
                code = data.s_info_windcode;
                [code,ia,~] = unique(code);
                
                % ��ʼ�����
                result = nan(size(code,1),length(db_names));
                
                ia(length(ia)+1) = length(data.s_info_windcode)+1;
                
                for j=1:length(code)
                    
                   data_j = data(ia(j):(ia(j+1)-1),:);
                                      
                   [~,ir,~] = unique(data_j.rank_rpt);

                   if(length(ir)<12)
                       
                       result(j,:) = nan(1,length(db_names));
                       continue;
                   end

                   data_j = data_j(ir,:);
                   x = data_j.rank_rpt;
                   x = x - mean(x);
                   
                   for k = 1:length(db_names)
                       eval(['y = data_j.',db_names{k},';']);                       
                       ym = mean(y);
                       y = y - ym;
                       if(ym<0)
                          continue;                      
                       end
                       result(j,k) = -regress(y,x)/ym;
                   end
                   
                end
               
                result = array2table(result,'VariableNames',db_names); %#ok<NASGU>
                
            case 'MEAN'
                
                % ������ֵ��һ��ǰֵ��ƽ��, �ڼ�����ת�ʵ�����ʱ��Ҫ
                
                % ѡ���µ�4�ڵ�������
                data = data_last(data_last.rank_rpt==1 | data_last.rank_rpt==5,:);

                % ���еĴ���
                code = data.s_info_windcode;
                code = unique(code);

                % ������ĸ����ȶ�Ӧ�ĵ�������
                s1 = data(data.rank_rpt==1,:);
                s5 = data(data.rank_rpt==5,:);
                                
                % ��ʼ�����
                result = nan(size(code,1),size(data,2));
                result = array2table(result,'VariableNames',data.Properties.VariableNames);

                % �����µ��ĸ����ȶ�Ӧ���ֶ���Ӽ���ttm
                % ��������ͬһ��(��)����ͬһactual_ann_dt�ж�����¼���������ֻ�õ�����������
                [Lia,Locb] = ismember(code,s1.s_info_windcode);
                result(Lia,db_names) = s1(Locb(Locb>0),db_names);
                season1 = nan(size(result,1),1);
                season1(Lia) = s1.report_period(Locb(Locb>0));

                [Lia5,Locb5] = ismember(code,s5.s_info_windcode);
                add = array2table(nan(size(result)),'VariableNames',result.Properties.VariableNames);
                add(Lia5,db_names) = s5(Locb5(Locb5>0),db_names);
                result(:,db_names) = array2table((table2array(result(:,db_names)) + table2array(add(:,db_names)))/2);
                season5 = nan(size(result,1),1);
                season5(Lia5) = s5.report_period(Locb5(Locb5>0));

                % ���s5��Ӧ��season�ǲ���һ����ǰ
                l5s = nan(size(result,1),1);
                l5s(Lia) = lastNseason(season1(Lia),4); % 4������֮ǰ����ȥ����ͬ����
                result(season5~=l5s,:) = array2table(nan(size(result(season5~=l5s,:)))); %#ok<NASGU>
                
            otherwise
                warning('Error: rpt_type is not in {''LR'',''SQ'',''LYR'',''TTM'',''YOY'',''LTG'',''MEAN''}');
        end
        
        % �ϲ������stk_codes�͵���pit�����е�code
        % �Ա��������stk_codes����
%         union_codes = union(code,stk_codes);
        
        % �ҵ�result�����Ӧ����
%         [~,cols] = ismember(code,union_codes); %#ok<*ASGLU>
        
        % ��stk_codes��ȫ����Ҫ��¼ȱʧ�����Ա���h5�ļ��в�ȫ
%         if(length(stk_codes)<length(union_codes))
%             [~,h5_cols] = ismember(stk_codes,union_codes);
%         else
%             h5_cols = 1:length(stk_codes); %#ok<*NASGU>
%         end
        
        % �ѵõ��Ľ�����������ֶ��������ı����е�һ��
        for k=1:length(db_names)
            eval(['tmp = result(:,{''s_info_windcode'',''date'',''',db_names{k},'''});']);
            eval([db_names{k},'=[',db_names{k},';tmp];']);
%             eval(['tmp = result.',db_names{k},';']);
%             if(length(stk_codes) < length(union_codes))
%                 eval(['tmp_tbl = nan(size(',db_names{k},',1),length(union_codes));']);
%                 eval(['tmp_tbl(:,h5_cols) = ',db_names{k},';']);
%                 eval([db_names{k},' = tmp_tbl;']);
%             end
%             eval([db_names{k},'(i,cols) = tmp'';']);
        end
        
        % ��չstk_codes
%         stk_codes = union_codes;
        
        disp(i);
        
    end 
    
%     tot_height = zeros(length(db_names),1);
%     
%     for k = 1:length(db_names)
%         
%         for i = Smin:T
%             eval(['tot_height(k) = tot_height(k) + height(',db_names{k},'_',dt{i},');'])
%         end
%         
%         tot_height(k) = tot_height(k) + eval(['height(',db_names{k},');']);
%         
%     end
%     
%     for k = 1:length(db_names)
%         
%         h = eval(['height(',db_names{k},')']);
%         w = 3; %#ok<NASGU>
%         tmp = table(cell(tot_height(k),1),cell(tot_height(k),1),nan(tot_height(k),1),'VariableNames',eval(['{''s_info_windcode'',''date'',''',db_names{k},'''}'])); %#ok<NASGU>
%         if h>0
%             eval(['tmp(1:h,:) = ',db_names{k},';']);
%         end
%         eval([db_names{k},'= tmp;']);
%         
%         for i=Smin:T
%             hi = eval(['height(',db_names{k},'_',dt{i},')']);
%             eval([db_names{k},'((h+1):(h+hi),:) = ',db_names{k},'_',dt{i},';']);
%             h = h+hi;
%         end
%         
%     end
    
    
    % �洢���
    for k=1:length(db_names)
%         eval(['hdf5write(tgt_file{',int2str(k),'},''date'',dt, ''stk_code'',stk_codes,' '''', ...
%                 db_names{k}, ''',','' db_names{k}, ');']); 
        eval(['save(''',tgt_file{k},''',''',db_names{k},''');']);
    end
    
%     all_stk_codes = stk_codes;
    
end

% ��pit_20190201.mat��ʽ���ļ�����ȡ�������ַ���
function dt = file2dt(filename)

    dt = filename(5:12);

end

% Ѱ��season֮ǰn�����ȵĶ�Ӧ����
function lastNs = lastNseason(season,n)

    lastNs = zeros(size(season));
    
    for i=1:length(season)
        tmp_s = season(i);
        for j=1:n
            tmp_s = last_season(tmp_s);
        end
        lastNs(i) = tmp_s;
    end
    
end

