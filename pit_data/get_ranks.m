function tbl = get_ranks(data)

    sort_data =  sortrows(data,{'s_info_windcode','report_period','actual_ann_dt'},{'ascend','descend','descend'});

    code = sort_data.s_info_windcode;
    rpt = sort_data.report_period;
    ann = sort_data.actual_ann_dt;

    sc = ones(size(code,1),1);
    for i = 2:size(code,1)
        if(~strcmp(code(i,1),code(i-1,1)))
            sc(i) = 0;
        end	
    end


    sr= ones(size(rpt,1),1);
    for i = 2:size(rpt,1)
        if(rpt(i,1)~=rpt(i-1,1))
            sr(i) = 0;
        end	
    end


    sa = ones(size(ann,1),1);
    for i = 2:size(ann,1)
        if(ann(i,1)~=ann(i-1,1))
            sa(i) = 0;
        end
    end

    rank_ann = zeros(size(code));
    rank_ann(1,1) = 1;
    for i = 2:size(code,1)
        rank_ann(i,1) = ( rank_ann(i-1,1) - sa(i,1) ) * sc(i,1) * sr(i,1) + 1;
    end

    rank_rpt = zeros(size(code));
    rank_rpt(1,1) = 1;
    for i = 2:size(code,1)
        rank_rpt(i,1) = ( rank_rpt(i-1,1) - sr(i,1) ) * sc(i,1) + 1;
    end

    tbl = sort_data;
    tbl.rank_rpt = rank_rpt;
    tbl.rank_ann = rank_ann;
    
end
