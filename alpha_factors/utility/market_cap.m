function [] = market_cap( capital_folder, close_folder, stk_codes, output_folder, cap_type)
% 计算总市值和A股流通市值
% cap_type = 'tot_cap' or 'float_cap'

    % capital_folder是存放pit_data的位置
    capital_files = dir(capital_folder); % 取得文件列表 
    close_files = dir(close_folder);
    
    % 循环取得文件名以及是否是文件夹的标志isdir
    cap_filename = cell(length(capital_files),1);
    isdir = zeros(length(capital_files),1);
    for i=1:length(capital_files)
        cap_filename{i} = capital_files(i).name;
        isdir(i) = capital_files(i).isdir;
    end
    
    % 循环取得文件名以及是否是文件夹的标志isdir
    close_filename = cell(length(close_files),1);
    isdir = zeros(length(close_files),1);
    for i=1:length(close_files)
        close_filename{i} = close_files(i).name;
        isdir(i) = close_files(i).isdir;
    end
    
    % 去除所有的文件夹
    cap_filename = cap_filename(isdir==0);
    T = length(cap_filename);  % 文件个数
    
    % dt是用来从文件名中截取日期字符串的容器
    dt_cap = cell(length(cap_filename),1);
    ndt_cap = nan(length(cap_filename),1);
    for i=1:T
        dt_cap{i} = file2dt(cap_filename{i}); % 从文件名截取日期字符串
        ndt_cap(i) = datenum(dt_cap{i},'yyyymmdd');
    end
    
    close_filename = close_filename(isdir==0);
    T = length(close_filename);  % 文件个数
    
    % dt是用来从文件名中截取日期字符串的容器
    dt_close = cell(length(close_filename),1);
    ndt_close = nan(length(close_filename),1);
    for i=1:T
        dt_close{i} = file2dt(close_filename{i}); % 从文件名截取日期字符串
        ndt_close(i) = datenum(dt_close{i},'yyyymmdd');
    end
    
    dt = intersect(dt_cap,dt_close);
    ndt = intersect(ndt_cap,ndt_close);
    T = length(dt);
    
    % 设置用在check_exist里面的struct p
    p.all_trading_dates_ = dt;
    p.all_trading_dates = ndt;
    p.stk_codes = stk_codes; %#ok<STRNU>
    
    N = length(stk_codes); %#ok<NASGU>
    
    % 查询原先的tot_cap文件确定需要更新的起始日
    tgt_file = [output_folder,'/',cap_type,'.h5']; %#ok<NASGU>
    eval(['[S,',cap_type,'] = check_exist(tgt_file,cap_type,p,T,N);']);
    
    if(S==0)
        return;
    end
    
    for i=S:T
        
        load([capital_folder,'/',cap_filename{i}]); % 读取当日的pit_data
        load([close_folder,'/',close_filename{i}]);
        
        cap_codes = cap.s_info_windcode;
        close_codes = price.s_info_windcode;
        
        union_codes = union(union(stk_codes,cap_codes),close_codes);
        
        [~,cap_cols] = ismember(cap_codes,union_codes);
        [~,close_cols] = ismember(close_codes,union_codes);
        
        result_cap = nan(1,length(union_codes));
        result_close = nan(1,length(union_codes));
        if(strcmp(cap_type,'tot_cap'))
            result_cap(1,cap_cols) = cap.tot_shr;
        else
            if(strcmp(cap_type,'float_cap'))
                result_cap(1,cap_cols) = cap.float_a_shr;
            else
                disp('tot_cap.m: cap_type is not in {''tot_cap'',''float_cap''}');
            end
        end
        result_close(1,close_cols) = price.s_dq_close;
        
        result = result_cap .* result_close .* 10000; %#ok<NASGU>
        
        % 若stk_codes不全则需要记录缺失的列以便在h5文件中补全
        [~,h5_cols] = ismember(stk_codes,union_codes); %#ok<ASGLU>
        
        if(length(stk_codes) < length(union_codes))
            eval(['tmp_tbl = nan(size(',cap_type,',1),length(union_codes));']);
            eval(['tmp_tbl(:,h5_cols) = ',cap_type,';']);
            eval([cap_type,' = tmp_tbl;']);
        end
        eval([cap_type,'(i,:) = result;']);
        
        % 扩展stk_codes
        stk_codes = union_codes;
        
        disp(i);
        
    end
   
    eval(['hdf5write(tgt_file,''date'',dt, ''stk_code'',stk_codes,''',cap_type,''',',cap_type,');']);
    
    
end

% 从pit_20190201.mat格式的文件名中取得日期字符串
function dt = file2dt(filename)

    dt = filename(5:12);

end

