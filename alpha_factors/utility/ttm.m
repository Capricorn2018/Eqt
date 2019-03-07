function [all_stk_codes]=ttm(input_folder, stk_codes, db_names, output_folder)
% trailing twelve month����
% ��ÿ���pit_data�н�ȡ�����ֶΣ����ڵ������ļ���
% db_names�����ݿ��ֶ���, ����AShareIncome�����net_profit_excl_min_int_inc
% input_folder = 'D:/Projects/pit_data/mat/income/'; �Ǵ��pit_data��λ��
% stk_codes����wind�������s_info_windcode
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors/'; ��������Ž���ĵ�ַ

    % input_folder�Ǵ��pit_data��λ��
    files = dir(input_folder); % ȡ���ļ��б�    
    
    % ��ֹ���˼��ļ��е�ַ��
    if(output_folder(end)~='/' && output_folder(end)~='\') 
        output_folder = [output_folder,'/']; 
    end
    
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
    N = length(stk_codes);
    
    % dt���������ļ����н�ȡ�����ַ���������
    dt = cell(length(filename),1);
    ndt = nan(length(filename),1);
    for i=1:T
        dt{i} = file2dt(filename{i}); % ���ļ�����ȡ�����ַ���
        ndt(i) = str2double(dt{i});
    end
    
    % ��¼ÿ���ֶ���Ҫ���µ���ʼ��
    S = zeros(length(db_names),1);
    p.all_trading_dates_ = dt;
    p.all_trading_dates = ndt;
    p.stk_codes = stk_codes; %#ok<STRNU>
    
    % ��ʼ�����
    % result = nan(length(filename),length(stk_codes));
    tgt_file = cell(length(db_names),1);
    for i=1:length(db_names)
%         eval([db_names{i},' = nan(length(filename),length(stk_codes));']);
%         eval([db_names{i},' = array2table(',db_names{i},',''VariableNames'',colnames);']);
        tgt_file{i} = [output_folder,'TTM_',db_names{i},'.h5'];
        eval(['[S(',int2str(i),'),',db_names{i},'] = check_exist(''',tgt_file{i},''',''/',db_names{i},''',p,T,N);']);
    end
    
    Smax = max([S;1]);
    
    % ѭ����pit�����н�ȡ���µ��걨��������Ҫ���ֶ�
    for i = Smax:T
        
        load([input_folder,filename{i}]); % ��ȡ���յ�pit_data
        
        % ѡ���µ�4�ڵ�������
        data = single(single.rank_rpt<=4,:);  %#ok<NODEF>
        
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
        
        % ���s4��Ӧ��season�ǲ���һ����ǰ
        l4s = nan(size(result,1),1);
        l4s(Lia) = last4season(season1(Lia));
        result(season4~=l4s,:) = array2table(nan(size(result(season4~=l4s,:))));
        
        % test
        union_codes = union(code,stk_codes);
        
        % �ҵ�result�����Ӧ����
        [~,cols] = ismember(code,union_codes); %#ok<*ASGLU>
        if(length(stk_codes)<length(union_codes))
            [~,h5_cols] = ismember(stk_codes,union_codes);
        else
            h5_cols = 1:length(stk_codes); %#ok<*NASGU>
        end
        
        % �ѵõ��Ľ�����������ֶ��������ı����е�һ��
        for k=1:length(db_names)            
            eval(['tmp = result.',db_names{k},';']);
            if(length(stk_codes)<length(union_codes))
                eval(['tmp_tbl = nan(size(',db_names{k},',1),length(union_codes);']);
                eval(['tmp_tbl(:,h5_cols) = ',db_names{k},';']);
                eval([db_names{k},' = tmp_tbl;']);
            end
            eval([db_names{k},'(i,cols) = tmp'';']);
        end
        
        % ��չstk_codes
        stk_codes = union_codes;
                
        disp(i);
        
    end
    
    % �洢���
    for k=1:length(db_names)
%         eval([db_names{k},'.DATEN = DATEN;']);        
%         eval(['save(''',output_folder,'TTM_',db_names{k},'.mat'',''',db_names{k},''');']);
        eval(['hdf5write(tgt_file{',int2str(k),'},''date'',dt, ''stk_code'',stk_codes,' '''',db_names{k}, ''',','' db_names{k}, ');']); 
    end
    
    all_stk_codes = stk_codes;
    
end

% ��pit_20190201.mat��ʽ���ļ�����ȡ�������ַ���
function dt = file2dt(filename)
    dt = filename(5:12);
end

% �����¼�����Ӧ���ȵ���������֮ǰ��Ӧ��report_period
function last_4s = last4season(season)

    last_4s = zeros(size(season));
    
    for i=1:length(season)
        last_4s(i) = last_season(last_season(last_season(season(i))));
    end
    
end