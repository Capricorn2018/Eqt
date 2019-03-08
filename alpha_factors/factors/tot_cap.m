function [] = tot_cap( capital_folder, close_folder, stk_codes, output_folder)

    % capital_folder�Ǵ��pit_data��λ��
    capital_files = dir(capital_folder); % ȡ���ļ��б� 
    close_files = dir(close_folder);
    
    % ѭ��ȡ���ļ����Լ��Ƿ����ļ��еı�־isdir
    cap_filename = cell(length(capital_files),1);
    isdir = zeros(length(capital_files),1);
    for i=1:length(capital_files)
        cap_filename{i} = capital_files(i).name;
        isdir(i) = capital_files(i).isdir;
    end
    
    % ѭ��ȡ���ļ����Լ��Ƿ����ļ��еı�־isdir
    close_filename = cell(length(close_files),1);
    isdir = zeros(length(close_files),1);
    for i=1:length(close_files)
        close_filename{i} = close_files(i).name;
        isdir(i) = close_files(i).isdir;
    end
    
    % ȥ�����е��ļ���
    cap_filename = cap_filename(isdir==0);
    T = length(cap_filename);  % �ļ�����
    
    % dt���������ļ����н�ȡ�����ַ���������
    dt_cap = cell(length(cap_filename),1);
    ndt_cap = nan(length(cap_filename),1);
    for i=1:T
        dt_cap{i} = file2dt(cap_filename{i}); % ���ļ�����ȡ�����ַ���
        ndt_cap(i) = datenum(dt_cap{i},'yyyymmdd');
    end
    
    close_filename = close_filename(isdir==0);
    T = length(close_filename);  % �ļ�����
    
    % dt���������ļ����н�ȡ�����ַ���������
    dt_close = cell(length(close_filename),1);
    ndt_close = nan(length(close_filename),1);
    for i=1:T
        dt_close{i} = file2dt(close_filename{i}); % ���ļ�����ȡ�����ַ���
        ndt_close(i) = datenum(dt_close{i},'yyyymmdd');
    end
    
    dt = intersect(dt_cap,dt_close);
    ndt = intersect(ndt_cap,ndt_close);
    T = length(dt);
    
    % ��������check_exist�����struct p
    p.all_trading_dates_ = dt;
    p.all_trading_dates = ndt;
    p.stk_codes = stk_codes;
    
    N = length(stk_codes);
    
    % ��ѯԭ�ȵ�tot_cap�ļ�ȷ����Ҫ���µ���ʼ��
    tgt_file = [output_folder,'tot_cap.h5'];
    [S,tot_cap] = check_exist(tgt_file,'tot_cap',p,T,N);
    
    if(S==0)
        return;
    end
    
    for i=S:T
        
        load([capital_folder,cap_filename{i}]); % ��ȡ���յ�pit_data
        load([close_folder,close_filename{i}]);
        
        cap_codes = cap.s_info_windcode;
        close_codes = price.s_info_windcode;
        
        union_codes = union(union(stk_codes,cap_codes),close_codes);
        
        [~,cap_cols] = ismember(cap_codes,union_codes);
        [~,close_cols] = ismember(close_codes,union_codes);
        
        result_cap = nan(1,length(union_codes));
        result_close = nan(1,length(union_codes));
        result_cap(1,cap_cols) = cap.tot_shr;
        result_close(1,close_cols) = price.s_dq_close;
        
        result = result_cap .* result_close .* 10000;
        
        % ��stk_codes��ȫ����Ҫ��¼ȱʧ�����Ա���h5�ļ��в�ȫ
        [~,h5_cols] = ismember(stk_codes,union_codes);
        
        if(length(stk_codes) < length(union_codes))
            tmp_tbl = nan(size(tot_cap,1),length(union_codes));
            tmp_tbl(:,h5_cols) = tot_cap;
            tot_cap = tmp_tbl;
        end
        tot_cap(i,:) = result;
        
        % ��չstk_codes
        stk_codes = union_codes;
        
        disp(i);
        
    end
   
    hdf5write(tgt_file,'date',dt, 'stk_code',stk_codes,'tot_cap',tot_cap);
    
    
end

% ��pit_20190201.mat��ʽ���ļ�����ȡ�������ַ���
function dt = file2dt(filename)

    dt = filename(5:12);

end

