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
    
    % ��ȡ��Ž�����ļ�, ȷ��ÿ���ļ����µ������ڶ�Ӧ�������±�
    tgt_file = cell(length(db_names),1);
    for i=1:length(db_names)
        
        % Ŀ�����������ļ�
        tgt_file{i} = [output_folder,'/',rpt_type,'_',db_names{i},'.mat'];
        
        if exist(tgt_file{i},'file')==2 % ������ļ����� 
            
            x = load(tgt_file{i});
            x_DATEN = x.data.DATEN;
            
            % ���ļ��Ĺ�Ʊ������ձ�
            eval([db_names{i},'_code_map=x.code_map;']);
            
            % �ҳ������������ļ����µ������ڶ�Ӧ�±�
            idx = find(ndt>max(x_DATEN),1);
            
            if isempty(idx) %�����ļ�û����Ҫ���µ�����
                S(i) = 0;
            else
                S(i) = idx;
            end
            eval([db_names{i},'=cell(0);']);
            % �ڴ�Ž���ı�����һ��Ԫ���д��ԭ���ļ��е�����
            eval([db_names{i},'{1}=table2array(x.data);']); 
        else
            % ��û�з��ָ��ļ���S(i)=1����Ҫ��ͷ����
            S(i) = 1;
            eval([db_names{i},'=cell(0);']);
            eval([db_names{i},'_code_map=table();']);
        end
    end
    
    % ��Ҫ���µ�������ȡ��Сֵ����Ҫ��ʼ���µ��±�
    Smin = min(S(S>0));
    
    % ������Ҫ������ֱ�ӷ���
    if(max(S)==0)
        disp('cal_ttm_lr.m: no need to be updated.');
        return;
    end
    
    % ѭ����pit�����н�ȡ���µ��걨��������Ҫ���ֶ�
    for i = Smin:T
        
        x = load([input_folder,'/',filename{i}]); % ��ȡ���յ�pit_data
        fn = fieldnames(x); % ������ַ���ļ�����
        
        % ������Ҫ����һ�������ļ��еı�����
        if ~isempty(find(strcmp(fn,'data_last'),1))
            data_last = x.data_last(:,[db_names,'rank_rpt','s_info_windcode','report_period','season']);
            data_last.DATEN = repmat(ndt(i),height(data_last),1); % ��һ�����ݶ�Ӧ����
        else
            if ~isempty(find(strcmp(fn,'cap'),1))
                data_last = x.cap(:,[db_names,'rank_rpt','s_info_windcode']);
                data_last.DATEN = repmat(ndt(i),height(data_last),1);
            end
            if ~isempty(find(strcmp(fn,'price'),1))
                data_last = x.price(:,[db_names,'rank_rpt','s_info_windcode']);
                data_last.DATEN = repmat(ndt(i),height(data_last),1);
            end
        end
        if ~isempty(find(strcmp(fn,'single'),1))
            single = x.single(:,[db_names,'rank_rpt','s_info_windcode','report_period','season']);
            single.DATEN = repmat(ndt(i),height(single),1);
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
                [code,ia,~] = unique(code);

                % ������ĸ����ȶ�Ӧ�ĵ�������
                s1 = data(data.rank_rpt==1,:);
                s2 = data(data.rank_rpt==2,:);
                s3 = data(data.rank_rpt==3,:);
                s4 = data(data.rank_rpt==4,:);

                % ��ʼ�����
                result = data(ia,:);
                result(:,db_names) = array2table(nan(size(code,1),length(db_names)));
                

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
                result(season4~=l4s,db_names) = array2table(nan(size(result(season4~=l4s,db_names)))); %#ok<NASGU>
                
            case 'YOY'
                                
                % ѡ���µ�4�ڵ�������
                data = single(single.rank_rpt==1 | single.rank_rpt==5,:);

                % ���еĴ���
                code = data.s_info_windcode;
                [code,ia,~] = unique(code);

                % ������ĸ����ȶ�Ӧ�ĵ�������
                s1 = data(data.rank_rpt==1,:);
                s5 = data(data.rank_rpt==5,:);
                                
                % ��ʼ�����
                result = data(ia,:);
                result(:,db_names) = array2table(nan(size(code,1),length(db_names)));

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
                result(season5~=l5s,db_names) = array2table(nan(size(result(season5~=l5s,db_names)))); %#ok<NASGU>
                
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
               
                result = array2table(result,'VariableNames',db_names);
                result.s_info_windcode = code;
                result.DATEN = data.DATEN(ia(1:end-1));
                
            case 'MEAN'
                
                % ������ֵ��һ��ǰֵ��ƽ��, �ڼ�����ת�ʵ�����ʱ��Ҫ
                
                % ѡ���µ�4�ڵ�������
                data = data_last(data_last.rank_rpt==1 | data_last.rank_rpt==5,:);

                % ���еĴ���
                code = data.s_info_windcode;
                [code,ia,~] = unique(code);

                % ������ĸ����ȶ�Ӧ�ĵ�������
                s1 = data(data.rank_rpt==1,:);
                s5 = data(data.rank_rpt==5,:);
                                
                % ��ʼ�����
                result = data(ia,:);
                result(:,db_names) = array2table(nan(size(code,1),length(db_names)));

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
                result(season5~=l5s,db_names) = array2table(nan(size(result(season5~=l5s,db_names)))); %#ok<NASGU>
                
            otherwise
                warning('Error: rpt_type is not in {''LR'',''SQ'',''LYR'',''TTM'',''YOY'',''LTG'',''MEAN''}');
        end
        
        
        % ������õ��ĵ������ݰ����������ݵ����ƴ���cell��һ����
        for k=1:length(db_names)
            
            if i>S(k)
                
                % �ڽ���н�ȡ��Ӧ������������
                eval(['tmp = result(:,{''s_info_windcode'',''DATEN'',''',db_names{k},'''});']);
                
                % �õ���Ʊ������ձ�
                try
                    eval(['stk_codes = ',db_names{k},'_code_map.stk_codes;']);
                    eval(['stk_num = ',db_names{k},'_code_map.stk_num;']);
                catch
                    stk_codes = cell(0);
                    stk_num = nan(0);
                end

                % �ڶ��ձ��������Ƿ��е��ս���еĹ�Ʊ���벻������
                Lia = ismember(tmp.s_info_windcode,stk_codes);
                count = length(tmp.s_info_windcode(~Lia)); % ���ڶ��ձ��еĹ�Ʊ����
                % �Ѳ��ڶ��ձ��еĴ�����ں���
                stk_codes = [stk_codes;tmp.s_info_windcode(~Lia)]; %#ok<AGROW>
                if count>0
                    % ����ں�����˴���, ���ձ���Ҫ����˳��������, ע��ǰ��ı�Ų��ܶ�
                    stk_num = [stk_num;((max([stk_num;0])+1):(max([stk_num;0])+count))']; %#ok<AGROW>
                end

                % ���µĹ�Ʊ������ձ���Ѱ�Ҷ�Ӧ��stk_num��Ų����뵱�ս��
                [~,Locb] = ismember(tmp.s_info_windcode,stk_codes);
                tmp.stk_num = stk_num(Locb); % ������stk_num���뵱�ս��
                tmp = tmp(:,{'DATEN','stk_num',db_names{k}});

                tmp = table2array(tmp);

                % �ѵ��ս������cell�е�һ��, �������µ�code_map
                eval([db_names{k},'{i+1}=tmp;']);
                eval([db_names{k},'_code_map = table(stk_codes,stk_num);']);

            end
            
        end
                
        disp([rpt_type,dt(i)]);
        
    end 

    % �����н������mat�ļ�
    for k=1:length(db_names)

        % ��cell2matƴ��cell��ÿ����
        eval([db_names{k},'=cell2mat(',db_names{k},''');']);
        % Ȼ��תtable, ������
        eval(['data =array2table(',db_names{k},',''VariableNames'',{''DATEN'',''stk_num'',''',db_names{k},'''});']);
        % ��Ӧ���������ݵĴ�����ձ�
        code_map = eval([db_names{k},'_code_map;']); %#ok<NASGU>
        % �洢�ļ�
        eval(['save(''',tgt_file{k},''',''data'',''code_map'');']);
    end
    
    
end

% ��pit_20190201.mat��ʽ���ļ�����ȡ�������ַ���
function dt = file2dt(filename)

    dt = filename(5:12);

end

% Ѱ��ĳ����ĩ����֮ǰn�����ȵĶ�Ӧ����
% �����ж�TTM����ͬ��ָ�����õ�rpt_period�Ƿ���ȷ
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

