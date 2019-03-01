% ע�⣡���е�code��Ĭ�ϴ������ı����¼�ǰ���
% s_info_windcode, report_period desc, actual_ann_dt desc �������

function []=latest_rpt(input_folder, stk_codes, db_names, output_folder, rpt_type)
% ���±�������
% ��ÿ���pit_data�н�ȡ�����ֶΣ����ڵ������ļ���
% db_names�����ݿ��ֶ���, ����AShareIncome�����net_profit_excl_min_int_inc
% input_folder = 'D:/Projects/pit_data/mat/income/'; �Ǵ��pit_data��λ��
% stk_codes����wind�������s_info_windcode
% output_folder = 'D:/Projects_pit_data/mat/alpha_factors/'; ��������Ž���ĵ�ַ
% rpt_type = 'LYR' �����걨����
% rpt_type = 'SQ' ���±���������
% rpt_type = 'LR' ���¼�(��)������

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
    %result = nan(length(filename),length(stk_codes));
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
        
        if(strcmp(rpt_type,'LYR'))
            % ɸѡ�����걨
            data = data_last(data_last.season==4,:);  %#ok<NODEF>

            % ���еĴ���
            code = data.s_info_windcode;
            code = unique(code);

            % Ϊ��ֹdata�������ͬһ��Ʊ������������¼��״��
            % ÿ����Ʊֻѡ���������¼
            [~,Locb] = ismember(code,data.s_info_windcode);
            data = data(Locb,:);
            
        else
            if(strcmp(rpt_type,'SQ'))
                % ɸѡ���µĵ�������
                data = single(single.rank_rpt==1,:);  %#ok<NODEF>

                % ���еĴ���
                code = data.s_info_windcode;
                code = unique(code);
                
                % Ϊ��ֹdata�������ͬһ��Ʊ������������¼��״��
                % ÿ����Ʊֻѡ���������¼
                [~,Locb] = ismember(code,data.s_info_windcode);
                data = data(Locb,:);
                
            else
                if(strcmp(rpt_type,'LR'))
                    % ɸѡ���µļ�������
                    data = data_last(data_last.rank_rpt==1,:);  %#ok<NODEF>

                    % ���еĴ���
                    code = data.s_info_windcode;
                    code = unique(code);
                    
                    % Ϊ��ֹdata�������ͬһ��Ʊ������������¼��״��
                    % ÿ����Ʊֻѡ���������¼
                    [~,Locb] = ismember(code,data.s_info_windcode);
                    data = data(Locb,:);
                    
                else
                    disp('Error: rpt_type is not in {''LR'',''SQ'',''LYR''}');
                end
            end
        end
        
        % �ҵ�result�����Ӧ����
        [~,cols] = ismember(code,stk_codes); 
        cols = cols(cols>0); % ȥ����Ʊ�����stk_code����û�е�Ʊ
        data = data(cols>0,:); % ȥ����Ʊ�����stk_code����û�е�Ʊ
        
        for k=1:length(db_names)            
            eval(['tmp = data.',db_names{k},';']);
            eval([db_names{k},'(i,cols) = array2table(tmp'');']);
        end
        % result(i,cols) = array2table(earn');
        
        disp(i);
        
    end    
    
    % ������
    % result.DATEN = datenum_h5(dt);
    DATEN = datenum_h5(dt); %#ok<NASGU>
    
    % ��ֹ���˼��ļ��е�ַ��
    if(output_folder~='/' && output_folder(end)~='\') 
        output_folder = [output_folder,'/']; 
    end
    
    for k=1:length(db_names)
        eval([db_names{k},'.DATEN = DATEN;']);        
        eval(['save(''',output_folder,rpt_type,'_',db_names{k},'.mat'',''',db_names{k},''');']);
    end
    
    
end

% ��pit_20190201.mat��ʽ���ļ�����ȡ�������ַ���
function dt = file2dt(filename)

    dt = filename(5:12);

end

