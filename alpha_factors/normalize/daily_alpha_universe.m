function [] = daily_alpha_universe(trading_dates,universe_folder,factor_folder,cap_folder,output_folder)
% factor_folder�Ǵ洢����õ�����h5�ļ��ĵ�ַ,��Ҫ����factor��ʱ��ֻ��Ҫ����folder����alpha�������ݼ���
% cap_folder�Ǵ��tot_cap.h5�ĵ�ַ
% output_folder��׼�����ÿ��alpha���ݵĵ�ַ
% trading_dates��׼�����µ�alpha�����ļ�����, ����cell���string��ʽ
    
    % factor_folder�Ǵ洢����õ�����h5�ļ��ĵ�ַ
    files = dir(factor_folder); % ȡ���ļ��б�  
    % ѭ��ȡ���ļ����Լ��Ƿ����ļ��еı�־isdir
    filename = cell(length(files),1);
    isdir = zeros(length(files),1);
    for i=1:length(files)
        filename{i} = files(i).name;
        isdir(i) = files(i).isdir;
    end
    
    % ȥ�����е��ļ���
    filename = filename(isdir==0);
    
    % ��ȡcap������zscore�ļ�Ȩ
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
    
    % �����洢���е�alpha����,cell��ÿһ��Ԫ����һ��factor��matrix
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
%        cl_cap{j}(isnan(cl_cap{j})) = 0; %ȥ��nan
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
%         tmp_cap = cap; % Ϊ�˲�����ÿ��ѭ������һ����ʱ��������
        
        for j= 1:length(trading_dates)
            
            stk_codes = universe{j};
            [Lia_stk,Locb_stk] = ismember(stk_codes,stk_f);
            
            v = (cal_zscore(factor(j,Locb_stk(Locb_stk>0)),cl_cap{j}(Locb_stk(Locb_stk>0))/1e10));
            
%             % ��ֵ��Ȩ�������滯
%             v = (cal_zscore(factor(j,:),tmp_cap(j,:)/1e10))';% ת��
            cl_alpha{j}(Lia_stk,i) = v;

        end
        
    end
    
    try
    % ��alpha factors����д��Ԥ����ļ�����
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

