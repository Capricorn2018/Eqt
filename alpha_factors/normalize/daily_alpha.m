function [] = daily_alpha(stk_codes,trading_dates,input_folder,cap_folder,output_folder)
% input_folder�Ǵ洢����õ�����h5�ļ��ĵ�ַ,��Ҫ����factor��ʱ��ֻ��Ҫ����folder����alpha�������ݼ���
% cap_folder�Ǵ��tot_cap.h5�ĵ�ַ
% output_folder��׼�����ÿ��alpha���ݵĵ�ַ
% trading_dates��׼�����µ�alpha�����ļ�����, ����cell���string��ʽ
% stk_codes������Ҫ���ز��universe
    
    % input_folder�Ǵ洢����õ�����h5�ļ��ĵ�ַ
    files = dir(input_folder); % ȡ���ļ��б�  
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
    stk = xblank(h5read([cap_folder,'/tot_cap.h5'],'/stk_code'));
    dt = xblank(h5read([cap_folder,'/tot_cap.h5'],'/date'));

    [Lia_stk,Locb_stk] = ismember(stk_codes,stk);
    [Lia_dt,Locb_dt] = ismember(trading_dates,dt);

    cap = nan(length(trading_dates),length(stk_codes));

    cap(Lia_dt,Lia_stk) = m(Locb_dt(Locb_dt>0),Locb_stk(Locb_stk>0)); 
    
    % �����洢���е�alpha����,cell��ÿһ��Ԫ����һ��factor��matrix
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
        tmp_cap = cap; % Ϊ�˲�����ÿ��ѭ������һ����ʱ��������
        
        for j= 1:length(trading_dates)
            
            % ��ֵ��Ȩ�������滯
            v = (cal_zscore(factor(j,:),tmp_cap(j,:)/1e10))';% ת��
            cl_alpha{i}(j,:) = v;

        end
        
    end
    
    % ��alpha factors����д��Ԥ����ļ�����
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

