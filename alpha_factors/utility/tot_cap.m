function [] = tot_cap( capital_folder, close_folder, stk_codes, output_folder)

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
    p.stk_codes = stk_codes;
    
    N = length(stk_codes);
    
    % 查询原先的tot_cap文件确定需要更新的起始日
    tgt_file = [output_folder,'tot_cap.h5'];
    [S,tot_cap] = check_exist(tgt_file,'tot_cap',p,T,N);
    
    if(S==0)
        return;
    end
    
    for i=S:T
        
        load([capital_folder,cap_filename{i}]); % 读取当日的pit_data
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
        
        % 若stk_codes不全则需要记录缺失的列以便在h5文件中补全
        [~,h5_cols] = ismember(stk_codes,union_codes);
        
        if(length(stk_codes) < length(union_codes))
            tmp_tbl = nan(size(tot_cap,1),length(union_codes));
            tmp_tbl(:,h5_cols) = tot_cap;
            tot_cap = tmp_tbl;
        end
        tot_cap(i,:) = result;
        
        % 扩展stk_codes
        stk_codes = union_codes;
        
        disp(i);
        
    end
   
    hdf5write(tgt_file,'date',dt, 'stk_code',stk_codes,'tot_cap',tot_cap);
    
    
end

% 从pit_20190201.mat格式的文件名中取得日期字符串
function dt = file2dt(filename)

    dt = filename(5:12);

end

