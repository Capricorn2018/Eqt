function []=latest_yr(folder, stk_codes, db_names)
% ��ÿ���pit_data�н�ȡ�����ֶΣ����ڵ������ļ���
% db_names�����ݿ��ֶ���
% folder = 'D:/Projects/pit_data/mat/income/';

    % folder�Ǵ��pit_data��λ��
    files = dir(folder); % ȡ���ļ��б�
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
    %result = nan(length(filename),length(stk_codes));
    for i=1:length(db_names)
        eval([db_names{i},' = nan(length(filename),length(stk_codes));']);
        eval([db_names{i},' = array2table(',db_names{i},',''VariableNames'',colnames);']);
    end
    % table����������
    %result = array2table(result,'VariableNames',colnames);
    
    % ѭ����pit�����н�ȡ���µ��걨��������Ҫ���ֶ�
    for i = 1:length(filename)
        
        dt{i} = file2dt(filename{i}); % ���ļ�����ȡ�����ַ���
        load([folder,filename{i}]); % ��ȡ���յ�pit_data
        
        % ɸѡ�����걨
        data = data_last(data_last.season==4,:);  %#ok<NODEF>
        
        % bool��������Ƿ��Ǹù�Ʊ������һ���걨
        code = data.s_info_windcode;
        bool = ones(size(data,1),1);        
        for j = 2:size(data,1)
            if(strcmp(code(j),code(j-1))) 
                bool(j) = 0;    % ������һ����¼��code����ͬ��˵�������µ�
            end
        end
        
        % ɸѡ�������±���
        code = code(bool==1);
        
        % �ҵ�result�����Ӧ����
        [~,cols] = ismember(code,stk_codes); %#ok<ASGLU>
        
        for k=1:length(db_names)
            
            eval(['tmp = data.',db_names{k},'(bool==1);']);
            eval([db_names{k},'(i,cols) = array2table(tmp'');']);
        end
        %result(i,cols) = array2table(earn');
        
        disp(i);
        
    end    
    
    % ������
    %result.DATEN = datenum_h5(dt);
    DATEN = datenum_h5(dt); %#ok<NASGU>
    for k=1:length(db_names)
        eval([db_names{k},'.DATEN = DATEN;']);
        eval(['save(''D:/Projects/pit_data/',db_names{k},'.mat'',''',db_names{k},''');']);
    end
    
    
end


function dt = file2dt(filename)

    dt = filename(5:12);

end
