clear;clc;
tic
project_path       = 'D:\Projects\Eqt'; 
input_data_path    = 'D:\Capricorn\fdata';
output_data_path   = 'D:\Capricorn\index'; 
cd(project_path); addpath(genpath(project_path));
mkdir_(output_data_path);

%% ���
%  1.  index_self ������ָ���ĵ�λ
%  2.  index_membs �� ����ָ���ĳɷ�
%  3.  num_of_stks_index�� ����ָ���ĳɷֹɸ���
%  4.  index_names: ����ָ��������
%% ȫA
[index_self,index_membs,num_of_stks_index,alpha_factors]= build_base_index(input_data_path);

% t = table2array(index_self);
% c = t(2:end,2:end)./t(1:end-1,2:end) - repmat(t(2:end,1)./t(1:end-1,1),1,size(t,2)-1);
%corr(c)

index_names = [{'ȫA'};alpha_factors];
save([output_data_path,'\all_A.mat'],'index_self','index_membs','num_of_stks_index','index_names');
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    