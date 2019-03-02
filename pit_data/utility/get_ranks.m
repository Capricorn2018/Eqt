function tbl = get_ranks(data)

    % 先按照code/report/ann的顺序排序
    sort_data =  sortrows(data,{'s_info_windcode','report_period','actual_ann_dt','ann_dt','statement_type_int'},{'ascend','descend','descend','descend','ascend'});

    code = sort_data.s_info_windcode;
    rpt = sort_data.report_period;
    ann = sort_data.actual_ann_dt;

    % 初始化, 本行与上一行是否一致的sign
    sc = ones(size(code,1),1);
    sr= ones(size(rpt,1),1);
    % sa = ones(size(ann,1),1);
    sa = zeros(size(ann,1),1);
    
    for i = 2:size(code,1)
        
        % 若本行code与上一行不一致则sign赋值为0
        if(~strcmp(code(i,1),code(i-1,1)))
            sc(i) = 0;
        end	
        
        % 若本行rpt与上一行不一致则sign赋值为0
        if(rpt(i,1)~=rpt(i-1,1))
            sr(i) = 0;
        end
        
        %%%%% 这一句是与 sa = ones(size(ann,1),1); 配对的,
        %%%%% 因为有同一ann_dt有数条相同report_period的情况所以注释掉
        % 若本行ann与上一行不一致则sign赋值为0
%         if(ann(i,1)~=ann(i-1,1))
%             sa(i) = 0;
%         end
        
    end
    
    % 初始化rank_rpt, 即对于每个code的报告期从晚到早的排序
    rank_rpt = zeros(size(code));
    rank_rpt(1,1) = 1;
    % 初始化rank_ann, 即对于每个code的每个报告期, 公布时间从晚到早的排序
    rank_ann = zeros(size(code));
    rank_ann(1,1) = 1;    
    
    for i = 2:size(code,1)
        % 用累加的方法得到排序
        rank_ann(i,1) = ( rank_ann(i-1,1) - sa(i,1) ) * sc(i,1) * sr(i,1) + 1;
        rank_rpt(i,1) = ( rank_rpt(i-1,1) - sr(i,1) ) * sc(i,1) + 1;
    end

    % 结果赋值, 把rank_rpt和rank_ann加到排序后的结果上
    tbl = sort_data;
    tbl.rank_rpt = rank_rpt;
    tbl.rank_ann = rank_ann;
    
end
