function [] = daily_alpha(stk_codes,trading_dates,input_folder,cap_folder,output_folder)
% input_folder是存储计算好的因子h5文件的地址,需要增加factor的时候只需要换个folder放新alpha因子数据即可
% cap_folder是存放tot_cap.h5的地址
% output_folder是准备存放每日alpha数据的地址
% trading_dates是准备更新的alpha因子文件日期, 存在cell里的string格式
% stk_codes就是需要做回测的universe
    
    % input_folder是存储计算好的因子h5文件的地址
    files = dir(input_folder); % 取得文件列表  
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
    stk = xblank(h5read([cap_folder,'/tot_cap.h5'],'/stk_code'));
    dt = xblank(h5read([cap_folder,'/tot_cap.h5'],'/date'));

    [Lia_stk,Locb_stk] = ismember(stk_codes,stk);
    [Lia_dt,Locb_dt] = ismember(trading_dates,dt);

    cap = nan(length(trading_dates),length(stk_codes));

    cap(Lia_dt,Lia_stk) = m(Locb_dt(Locb_dt>0),Locb_stk(Locb_stk>0)); 
    
    % 用来存储所有的alpha因子,cell的每一个元素是一个factor的matrix
    cl_alpha = cell(length(filename),1);
    
    factorname = cell(length(filename),1);
    for i=1:length(filename)
        
        factorname{i} = get_tag(filename{i});
        
    end
    
    for i=1:length(filename)
        
        f = filename{i};
        fn = factorname{i};
        
        m = h5read([input_folder,'/',f],['/',fn]);
        stk = xblank(h5read([input_folder,'/',f],'/stk_code'));
        dt = xblank( h5read([input_folder,'/',f],'/date'));
        
        [Lia_stk,Locb_stk] = ismember(stk_codes,stk);
        [Lia_dt,Locb_dt] = ismember(trading_dates,dt);
        
        factor = nan(length(trading_dates),length(stk_codes));
        
        factor(Lia_dt,Lia_stk) = m(Locb_dt(Locb_dt>0),Locb_stk(Locb_stk>0));
        cl_alpha{i} = nan(size(factor));
        tmp_cap = cap; % 为了并行在每次循环建立一个临时变量副本
        
        for j= 1:length(trading_dates)
            
            % 市值加权因子正规化
            v = (cal_zscore(factor(j,:),tmp_cap(j,:)/1e10))';% 转置
            cl_alpha{i}(j,:) = v;

        end
        
    end
    
    % 将alpha factors按日写入预设的文件夹中
    for j = 1:length(trading_dates)
        
        alpha_file = [output_folder,'/alpha_',trading_dates{j},'.mat'];
        alpha = nan(length(stk_codes),length(filename));
        
        for i = 1:length(filename)
            
            alpha(:,i) = cl_alpha{i}(j,:)';
            
        end
        
        alpha = [stk_codes,array2table(alpha)];
        alpha.Properties.VariableNames = [{'stk_codes'},factorname'];
        
        save(alpha_file,'alpha');
        
    end
    
end



function tag = get_tag(file)

    str = strsplit(file,'.');
    
    tag = str{1};

end

