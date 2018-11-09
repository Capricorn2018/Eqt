function [x,y] = q_table_k(conn, q,x,y,k)
     
     u = 0;
     while isempty(y)&&u<=k
        [x,y] = q_table( conn,q);
        u = u+1;
     end
end