function [] = daily_alpha(stk_codes,trading_dates,input_folder,cap_folder,output_folder)
% eq_weight 汇总alpha_factors 等权
% input_folder是存储计算好的因子h5文件的地址
% cap_folder是存放tot_cap.h5的地址
% output_folder是准备存放每日alpha数据的地址
% trading_dates是准备更新的alpha因子文件日期, 存在cell里的string格式
    
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
    
    for i=1:length(filename)
        
        f = filename{i};
        factor_name = get_tag(f);
        
        m = h5read([input_folder,'/',f],['/',factor_name]);
        stk = xblank(h5read([input_folder,'/',f],'/stk_code'));
        dt =xblank( h5read([input_folder,'/',f],'/date'));
        
        [Lia_stk,Locb_stk] = ismember(stk_codes,stk);
        [Lia_dt,Locb_dt] = ismember(trading_dates,dt);
        
        factor = nan(length(trading_dates),length(stk_codes));
        
        factor(Lia_dt,Lia_stk) = m(Locb_dt(Locb_dt>0),Locb_stk(Locb_stk>0));
        
        for j=1:length(trading_dates)
            
            % 市值加权因子正规化
            v = (cal_zscore(factor(j,:),cap(j,:)/1e10))'; % 转置 
            
            % 这里需要加上exist的判断，如果不存在则建立新文件
            alpha_file = [output_folder,'/alpha_',trading_dates{j},'.mat'];
            if exist(alpha_file,'file')==2
                % 这个文件里面只有一个变量叫alpha，用来存储当日正规化后因子值
                load(alpha_file); 
                alpha_stk = alpha.stk_codes;
                [Lia,Locb] = ismember(stk_codes,alpha_stk); %#ok<ASGLU>
                eval(['alpha.',factor_name,'=nan(size(alpha,1),1);']);
                try
                    eval(['alpha.',factor_name,'(Locb)=v(Lia);']);
                catch
                    disp('CNM');
                end
                save(alpha_file,'alpha');
            else
                alpha = table(stk_codes,v,'VariableNames',{'stk_codes',factor_name});
                save(alpha_file,'alpha');
            end
        end
        
    end

end

function v = xblank(x)

    v = cell(length(x),1);

    for i=1:length(x)
        
        v{i} = deblank(x{i});
        
    end

end

function tag = get_tag(file)

    str = strsplit(file,'.');
    
    tag = str{1};

end
