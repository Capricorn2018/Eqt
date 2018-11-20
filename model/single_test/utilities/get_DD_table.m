function [X,DD] = get_DD_table(Date,Price)

    T = length(Date);
    DD    = zeros(T,1);
    for i  = 1: T
        DD(i,1) = Price(i,1)/max(Price(1:i,1))-1;  
    end

    DD_table = [0,0,0,0];

    idx1 = 1;
    while idx1<T
        tmp_DD_table  = zeros(1,4);

        tmp_DD_table(1,1) = idx1;
        k = find(DD(idx1+1:end)==0,1,'first');


        if  ~isempty(k)
             tmp_DD_table(1,3) = idx1+ k;
        else
            tmp_DD_table(1,3)  = T;
        end
        [tmp_DD_table(1,4),idx]  = min(DD(idx1: tmp_DD_table(1,3)));
        tmp_DD_table(1,2) =  idx1+idx-1;

        DD_table = [DD_table;tmp_DD_table];

        idx1 = tmp_DD_table(1,3)+ find(DD(tmp_DD_table(1,3):end)<0,1,'first')-2;

        if isempty(k)
           break;
        end
    end

    DD_table(1,:) = [];
    
    DD_table_ = cell(size(DD_table,1),3);

    for i  = 1 : size(DD_table,1)
        DD_table_{i,1} = datestr(Date(DD_table(i,1)),29);
        DD_table_{i,2} = datestr(Date(DD_table(i,2)),29);
        DD_table_{i,3} = datestr(Date(DD_table(i,3)),29);
    end
 
     DD_table__ = zeros(size(DD_table,1),2);
     DD_table__(:,1) = DD_table(:,2) - DD_table(:,1);
     DD_table__(:,2) = DD_table(:,3) - DD_table(:,2);
     
     X = table(DD_table_(:,1),DD_table_(:,2),DD_table_(:,3),DD_table__(:,1),DD_table__(:,2),DD_table(:,4),...
               DD_table(:,1), DD_table(:,2), DD_table(:,3),...
              'VariableNames',{'Start','Low','End','Updays','Donwdays','DD','I1','I2','I3'});
end