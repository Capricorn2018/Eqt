function [x,y] = q_table_n( conn,q,k)
    [x,y] = q_table( conn,q);
    [x,y] = q_table_k(conn, q,x,y,k); 
end

