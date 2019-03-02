function tbl = get_ranks(data)

    % �Ȱ���code/report/ann��˳������
    sort_data =  sortrows(data,{'s_info_windcode','report_period','actual_ann_dt','ann_dt','statement_type_int'},{'ascend','descend','descend','descend','ascend'});

    code = sort_data.s_info_windcode;
    rpt = sort_data.report_period;
    ann = sort_data.actual_ann_dt;

    % ��ʼ��, ��������һ���Ƿ�һ�µ�sign
    sc = ones(size(code,1),1);
    sr= ones(size(rpt,1),1);
    % sa = ones(size(ann,1),1);
    sa = zeros(size(ann,1),1);
    
    for i = 2:size(code,1)
        
        % ������code����һ�в�һ����sign��ֵΪ0
        if(~strcmp(code(i,1),code(i-1,1)))
            sc(i) = 0;
        end	
        
        % ������rpt����һ�в�һ����sign��ֵΪ0
        if(rpt(i,1)~=rpt(i-1,1))
            sr(i) = 0;
        end
        
        %%%%% ��һ������ sa = ones(size(ann,1),1); ��Ե�,
        %%%%% ��Ϊ��ͬһann_dt��������ͬreport_period���������ע�͵�
        % ������ann����һ�в�һ����sign��ֵΪ0
%         if(ann(i,1)~=ann(i-1,1))
%             sa(i) = 0;
%         end
        
    end
    
    % ��ʼ��rank_rpt, ������ÿ��code�ı����ڴ����������
    rank_rpt = zeros(size(code));
    rank_rpt(1,1) = 1;
    % ��ʼ��rank_ann, ������ÿ��code��ÿ��������, ����ʱ������������
    rank_ann = zeros(size(code));
    rank_ann(1,1) = 1;    
    
    for i = 2:size(code,1)
        % ���ۼӵķ����õ�����
        rank_ann(i,1) = ( rank_ann(i-1,1) - sa(i,1) ) * sc(i,1) * sr(i,1) + 1;
        rank_rpt(i,1) = ( rank_rpt(i-1,1) - sr(i,1) ) * sc(i,1) + 1;
    end

    % �����ֵ, ��rank_rpt��rank_ann�ӵ������Ľ����
    tbl = sort_data;
    tbl.rank_rpt = rank_rpt;
    tbl.rank_ann = rank_ann;
    
end
