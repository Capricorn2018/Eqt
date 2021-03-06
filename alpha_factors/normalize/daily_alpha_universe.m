function [] = daily_alpha_universe(trading_dates,universe_folder,factor_folder,cap_folder,output_folder)
% factor_folder是存储计算好的因子h5文件的地址,需要增加factor的时候只需要换个folder放新alpha因子数据即可
% cap_folder是存放tot_cap.h5的地址
% output_folder是准备存放每日alpha数据的地址
% trading_dates是准备更新的alpha因子文件日期, 存在cell里的string格式
    
    % factor_folder是存储计算好的因子h5文件的地址
    files = dir(factor_folder); % 取得文件列表  
    % 循环取得文件名以及是否是文件夹的标志isdir
    filename = cell(length(files),1);
    isdir = zeros(length(files),1);
    for i=1:length(files)
        filename{i} = files(i).name;
        isdir(i) = files(i).isdir;
    end
    
    % 去除所有的文件夹
    filename = filename(isdir==0);
    
    % 读取cap用来做zscore的加权
    m = h5read([cap_folder,'/tot_cap.h5'],'/tot_cap');
    stk_cap = xblank(h5read([cap_folder,'/tot_cap.h5'],'/stk_code'));
    dt_cap = xblank(h5read([cap_folder,'/tot_cap.h5'],'/date'));

%     [Lia_stk,Locb_stk] = ismember(stk_codes,stk);
     [Lia_dt,Locb_dt] = ismember(trading_dates,dt_cap);
% 
     cap = nan(length(trading_dates),size(m,2));
% 
     cap(Lia_dt,:) = m(Locb_dt(Locb_dt>0),:); 
    
    
    
    factorname = cell(length(filename),1);
    for i=1:length(filename)
        
        factorname{i} = get_tag(filename{i});
        
    end
    
    % 用来存储所有的alpha因子,cell的每一个元素是一个factor的matrix
    cl_alpha = cell(length(trading_dates),1);
    cl_cap = cell(length(trading_dates),1);
    universe = cell(length(trading_dates),1);
    stk_all = cell(0);
    %perc = cell(length(trading_dates),1);
    for j = 1:length(trading_dates)
        
        u = load([universe_folder,'/universe_',trading_dates{j},'.mat']);
        
        tmp = u.universe.stk_codes;
        universe{j} = tmp;
        stk_all = union(stk_all,tmp);
        cl_alpha{j} = nan(length(tmp),length(filename));
        [Lia_cap,Locb_cap] = ismember(tmp,stk_cap);
        cl_cap{j} = nan(1,length(tmp));
        try
            cl_cap{j}(Lia_cap) = cap(j,Locb_cap(Locb_cap>0));
        catch
            disp(j);
        end
%        cl_cap{j}(isnan(cl_cap{j})) = 0; %去掉nan
        %perc{j} = u.percentage;
        
    end
    
    
    for i=1:length(filename)
        
        f = filename{i};
        fn = factorname{i};
        
        m = h5read([factor_folder,'/',f],['/',fn]);
        stk_f = xblank(h5read([factor_folder,'/',f],'/stk_code'));
        dt_f = xblank( h5read([factor_folder,'/',f],'/date'));
        
        factor = nan(length(trading_dates),size(m,2));
        [Lia_dt,Locb_dt] = ismember(trading_dates,dt_f);
        factor(Lia_dt,:) = m(Locb_dt(Locb_dt>0),:);
        
%         [Lia_stk,Locb_stk] = ismember(stk_codes,stk);
%         [Lia_dt,Locb_dt] = ismember(trading_dates,dt);
%         
%         factor = nan(length(trading_dates),length(stk_codes));
%         
%         factor(Lia_dt,Lia_stk) = m(Locb_dt(Locb_dt>0),Locb_stk(Locb_stk>0));
%         cl_alpha{i} = nan(size(factor));
%         tmp_cap = cap; % 为了并行在每次循环建立一个临时变量副本
        
        for j= 1:length(trading_dates)
            
            stk_codes = universe{j};
            [Lia_stk,Locb_stk] = ismember(stk_codes,stk_f);
            
            v = (cal_zscore(factor(j,Locb_stk(Locb_stk>0)),cl_cap{j}(Locb_stk(Locb_stk>0))/1e10));
            
%             % 市值加权因子正规化
%             v = (cal_zscore(factor(j,:),tmp_cap(j,:)/1e10))';% 转置
            cl_alpha{j}(Lia_stk,i) = v;

        end
        
    end
    
    try
    % 将alpha factors按日写入预设的文件夹中
    for j = 1:length(trading_dates)
        
        alpha_file = [output_folder,'/alpha_',trading_dates{j},'.mat'];
        alpha = cl_alpha{j};
        
        alpha = [universe{j}',array2table(alpha)];
        alpha.Properties.VariableNames = [{'stk_codes'},factorname'];
        
        save(alpha_file,'alpha');
        
    end
    catch
        disp('cao ni da ye');
    end
    
end



function tag = get_tag(file)

    str = strsplit(file,'.');
    
    tag = str{1};

end


