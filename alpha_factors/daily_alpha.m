function [] = daily_alpha(stk_codes,trading_dates,input_folder,cap_folder,output_folder)
% eq_weight ����alpha_factors ��Ȩ
% input_folder�Ǵ洢����õ�����h5�ļ��ĵ�ַ
% cap_folder�Ǵ��tot_cap.h5�ĵ�ַ
% output_folder��׼�����ÿ��alpha���ݵĵ�ַ
% trading_dates��׼�����µ�alpha�����ļ�����, ����cell���string��ʽ
    
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
            
            % ��ֵ��Ȩ�������滯
            v = (cal_zscore(factor(j,:),cap(j,:)/1e10))'; % ת�� 
            
            % ������Ҫ����exist���жϣ�����������������ļ�
            alpha_file = [output_folder,'/alpha_',trading_dates{j},'.mat'];
            if exist(alpha_file,'file')==2
                % ����ļ�����ֻ��һ��������alpha�������洢�������滯������ֵ
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
