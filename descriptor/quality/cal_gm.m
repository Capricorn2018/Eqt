function  cal_gm(p,a,K0,K1,K2,K3,K4,K5,K6)

      [~,q,d]     = get_rpt_table_by_ttm('AShareTTMHis', 'S_FA_GROSSPROFITMARGIN_TTM',1,a.input_data_path,p.stk_codes_);
  
%%
%     
%      K0 = 4; % ͬ�� 
%      K1 = 8; % ���ȶ���
%      K2 = 16;  % ���ȶ���
%      K3 = 12;% ���ھ�ֵ��
%      K4 = 8;%  ���ٶȡ�
%      K5 = 20; % �ع�
%      K6 = 8; % ������

     get_fundmental_stats(p,a,q,d,K0,K1,K2,K3,K4,K5,K6,'gm');
end