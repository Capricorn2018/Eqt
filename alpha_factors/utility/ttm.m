function []=ttm(input_folder, stk_codes, db_names, output_folder)
% trailing twelve month����
% ��ÿ���pit_data�н�ȡ�����ֶΣ����ڵ������ļ���
% db_names�����ݿ��ֶ���, ����AShareIncome�����net_profit_excl_min_int_inc
% input_folder = 'D:/Projects/pit_data/mat/income/single_season/'; �Ǵ��pit_data��λ��
% stk_codes����wind�������s_info_windcode
% output_folder = 'D:/Projects/pit_data/mat/alpha_factors/'; ��������Ž���ĵ�ַ

    % input_folder�Ǵ��pit_data��λ��
    files = dir(input_folder); % ȡ���ļ��б�
    N = length(files);  % �ļ�����
    
    % ѭ��ȡ���ļ����Լ��Ƿ����ļ��еı�־isdir
    filename = cell(N,1);
    isdir = zeros(N,1);
    for i=1:N
        filename{i} = files(i).name;
        isdir(i) = files(i).isdir;
    end
    
    % ȥ�����е��ļ���
    filename = filename(isdir==0);
    
    % dt���������ļ����н�ȡ�����ַ���������
    dt = cell(length(filename),1);
    
     % ��stk_codes��ȡ���ִ��벢��ǰ�����'ST'�Ա�����table������
    colnames = cell(length(stk_codes),1);
    for i = 1:length(stk_codes)
        colnames{i} = ['ST',stk_codes{i}(1:6)];
    end
    
    % ��ʼ�����
    % result = nan(length(filename),length(stk_codes));
    for i=1:length(db_names)
        eval([db_names{i},' = nan(length(filename),length(stk_codes));']);
        eval([db_names{i},' = array2table(',db_names{i},',''VariableNames'',colnames);']);
    end
    % table����������
    % result = array2table(result,'VariableNames',colnames);
    
    % ѭ����pit�����н�ȡ���µ��걨��������Ҫ���ֶ�
    for i = 1:length(filename)
        
        dt{i} = file2dt(filename{i}); % ���ļ�����ȡ�����ַ���
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
        
        
        % �ҵ�result�����Ӧ����
        [~,cols] = ismember(code,stk_codes); 
        cols = cols(cols>0); % ȥ����Ʊ�����stk_code����û�е�Ʊ
        result = result(cols>0,:); %#ok<NASGU> % ȥ����Ʊ�����stk_code����û�е�Ʊ
        
        % �ѵõ��Ľ�����������ֶ��������ı����е�һ��
        for k=1:length(db_names)            
            eval(['tmp = result.',db_names{k},';']);
            eval([db_names{k},'(i,cols) = array2table(tmp'');']);
        end
        % result(i,cols) = array2table(earn');
        
        disp(i);
        
    end    
    
    % ������
    % result.DATEN = datenum_h5(dt);
    DATEN = datenum_h5(dt); %#ok<NASGU>
    
    % ��ֹ���˼��ļ��е�ַ��
    if(output_folder(end)~='/' && output_folder(end)~='\') 
        output_folder = [output_folder,'/']; 
    end
    
    % �洢���
    for k=1:length(db_names)
        eval([db_names{k},'.DATEN = DATEN;']);        
        eval(['save(''',output_folder,'TTM_',db_names{k},'.mat'',''',db_names{k},''');']);
    end
    
    
end

% ��pit_20190201.mat��ʽ���ļ�����ȡ�������ַ���
function dt = file2dt(filename)
    dt = filename(5:12);
end