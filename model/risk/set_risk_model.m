function  [p,a] = set_risk_model(project_path,input_data_path,output_data_path)
    %%  ��·��
     a.data         =  [input_data_path,'\fdata'];
     a.sector       =  [output_data_path,'\risk\sector'];                  %mkdir_(a.sector);
     a.style        =  [output_data_path,'\risk\style'];                   %mkdir_(a.style);
     a.reggression  =  [output_data_path,'\risk\regression'];              %mkdir_(a.reggression);
     a.cov          =  [output_data_path,'\risk\cov'];                     %mkdir_(a.cov);
     a.spk          =  [output_data_path,'\risk\spk'];                     %mkdir_(a.spk);
     a.backtest     =  [output_data_path,'\risk\backtest'];                %mkdir_(a.backtest);
    % mkdir_([output_data_path,'\risk\backtest\regression']);
    % mkdir_([output_data_path,'\risk\backtest\style']);
    % a.index
    %%  ģ�͵Ļ�׼;T��N������securites_dates.h5 ������
     p.model.all_trading_dates = datenum_h5 (h5read([a.data,'\base_data\securites_dates.h5'],'/date'));      T = length(p.model.all_trading_dates);
     p.model.stk_codes         = stk_code_h5(h5read([a.data,'\base_data\securites_dates.h5'],'/stk_code'));  N = length(p.model.stk_codes);
     %% file check�� 
     p.file.stk  =      [a.data,'\base_data\stk_prices.h5'];              err_chk(p.file.stk,T,N);
     p.file.ind  =      [a.data,'\base_data\citics_stk_sectors_all.h5'];  err_chk(p.file.ind,T,N); % ������ҵ����  
     p.file.totalshrs = [a.data,'\base_data\capital.h5'];                 err_chk(p.file.totalshrs,T,N); % ����ֵ
     p.file.freeshrs  = [a.data,'\base_data\free_shares.h5'];             err_chk(p.file.freeshrs,T,N); % ������ͨ��ֵ
     p.file.status    = [a.data,'\base_data\stk_status.h5'];              err_chk(p.file.status,T,N);   % if(ST<>PT<>��ͣ����<>������<�ù�Ʊ������<>������>�ù�Ʊ������,0,1)
     p.file.sus       = [a.data,'\base_data\suspended.h5'];               err_chk(p.file.sus,T,N);      % if(ͣ�̣�1,0��
     p.file.base_index   = 'D:\Capricorn\index\all_A.mat';
     p.file.sector_codes = 'D:\Projects\Eqt\files\sector_codes.csv';
     p.file.sector_table = 'D:\Projects\Eqt\files\sector_table.csv';
     p.file.style_file   = 'D:\Projects\Eqt\files\styles.xlsx';   % style factors settings
     %%   
     x = [];
     for k = 1 : length(p.model.stk_codes),z = cell2mat(p.model.stk_codes(k)); x = [x,cellstr(z([8:9,1:6]))]; end
     p.model.stk_codes1 = x;  %  �г�����|��Ʊ���� e.g. SZ000001
     p.model.start_date  = datenum(2005,01,01);
     p.model.end_date    = datenum(2018,09,21);
     p.model.model_trading_dates  = p.model.all_trading_dates(p.model.all_trading_dates>= p.model.start_date&p.model.all_trading_dates<=p.model.end_date);
     load(p.file.base_index)  % Ĭ��Index0 Ϊcoverage universe Indexi(i>=0,...) Ϊ��ͬ��estimation universe(Index0Ҳ����Ϊestimation universe)
     p.model.indexlev  = index_self;     % ָ����λ
     p.model.indexmemb = index_membs;    % ָ��Ȩ��
     p.model.index_names = index_names;  % ָ������
     %%  ��ҵ����
      x = readtable(p.file.sector_table,'ReadRowNames',false,'ReadVariableNames',false);
      y = readtable(p.file.sector_codes,'ReadRowNames',false,'ReadVariableNames',false);
      snames  = cell(size(x,1),1);
      for i  = 1: size(x,1)
         snames{i,1} = strcat('Ind',num2str(i));
         tmp = table2array(y(i,:));
         p.model.ind_subcode.(['Ind',num2str(i)]) = tmp(~isnan(tmp))';  % risk model ��ÿ����ҵ��IndexX) �� ������ҵ�����mapping  X = 1,2,...
      end
      p.model.ind_names = table(snames,x.Var2,'VariableNames',{'Eng','Chn'});% risk model ��ÿ����ҵ����������
      
%       for i = 1 : length(index_names)-1
%          tmp = ismember(p.model.ind_names.Chn,x.Var2(ismember(x.Var1,index_names(i+1)),:));
%          p.model.alpha_code.(['Index',num2str(i)]) = p.model.ind_names(tmp,:); %IndexX�еġ�risk model ��ҵ��
%       end
%       p.model.alpha_code.Index0 =  p.model.ind_names ; % Index0����ָ�����壨��׼��index0��
    %% styles, ÿ�� descriptor ��Ӧһ�� factor Ȼ���� descriptor\descriptor.h5 �ǲ��Ǵ���
      p.style.styles01 = {'soe'};
      p.style.sty = readtable(p.file.style_file) ;
      p.style.sty.descriptors_ = cell(height(p.style.sty),1);
      for i = 1 : height(p.style.sty)
          x = cell2mat(p.style.sty.descriptors(i)); 
          idx = strfind(x,'-');
          if ~isempty(idx)
              p.style.sty.descriptors_{i,1} = [x(1:idx-1),'__',x(idx+1:end)];
          else
               p.style.sty.descriptors_{i,1} = p.style.sty.descriptors{i,1};
          end
      end
      p.style.sty = p.style.sty(p.style.sty.tag==1,:);
      for i = 1: height(p.style.sty)
         z =  exist( [input_data_path,'\descriptors\',cell2mat(p.style.sty.descriptors(i)),'.h5'],'file');
         if z==2
             p.file.(cell2mat(p.style.sty.descriptors_(i))) = [input_data_path,'\descriptors\',cell2mat(p.style.sty.descriptors(i)),'.h5'];
             err_chk(p.file.(cell2mat(p.style.sty.descriptors_(i))),T,N);
         else
             error(['Plz chk ',input_data_path,'\descriptors\',cell2mat(p.style.sty.descriptors(i)),'.h5']);
         end
      end
      p.style.style = unique(p.style.sty.factors);
    %% reg methord
     p.reg = 'ols';
     % p.reg = 'robust';
    
    %% cov �� factor covariance matrix estimation parameters  all values are reported in trading days
    p.cov.vol_HL   = 84;  % factor volatility half-life
    p.cov.nwlag_vol   = 10;  % newey-west volatility lags
    
    p.cov.corr_HL  = 504; % factor correlation half- life
    p.cov.nwlag_corr    = 3; % newey-west correlation lags
    
    p.cov.vra_HL = 21;  % �����ʳ�����˥��  half-life vol regrime adjustment 
    
    p.cov.cov_N   = 504; 
    p.cov.corr_N   = 504;   
    p.cov.vra_N = 126; 
    p.cov.simtimes = 10000;
    p.cov.small_eigen   = 1e-10;

    %% spk
    
    p.spk.spk_HL = 84;
    p.spk.nwlag  = 5;
    p.spk.nw_HL  = 252;
    p.spk.bayes  = 0.15;
    p.spk.vra_HL = 21;
    
    p.spk.spk_N  = 504;
    p.spk.nw_N   = 504;
    p.spk.vra_N  = 126;
    p.spk.h = 252;
    p.spk.E0 = 1.05;
    p.spk.groups = 10;
end

