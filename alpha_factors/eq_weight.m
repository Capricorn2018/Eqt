function alpha = eq_weight(stk_codes,trading_dates,input_folder,cap_folder)
% eq_weight ����alpha_factors ��Ȩ
    
    % input_folder�Ǵ��pit_data��λ��
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
    
    alpha = zeros(length(trading_dates),length(stk_codes));
    num = zeros(length(trading_dates),1); % ������¼ÿһ���ж��ٸ���Чfactor
    
    for i=1:length(filename)
        
        f = filename{i};
        
        m = h5read([input_folder,'/',f],['/',get_tag(f)]);
        stk = xblank(h5read([input_folder,'/',f],'/stk_code'));
        dt =xblank( h5read([input_folder,'/',f],'/date'));
        
        [Lia_stk,Locb_stk] = ismember(stk_codes,stk);
        [Lia_dt,Locb_dt] = ismember(trading_dates,dt);
        
        factor = nan(length(trading_dates),length(stk_codes));
        
        factor(Lia_dt,Lia_stk) = m(Locb_dt(Locb_dt>0),Locb_stk(Locb_stk>0));
        
        for j=1:length(trading_dates)
            v = cal_zscore(factor(j,:),cap(j,:)/1e10);
            if all(isnan(v))
                continue;
            end
            num(j) = num(j) + 1;
            alpha(j,:) = (alpha(j,:).*(num(j)-1) + v)./num(j);            
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
