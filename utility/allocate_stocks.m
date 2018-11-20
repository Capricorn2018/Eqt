function  u = allocate_stocks(m , n )
  % allocate m stocks into n groups
  % m = 3; n = 5;
  u = zeros(n,m);
  z = n/m *(1:(m-1));
  j = 1;
  for i  = 1 : n-1
      if i<= z(j)
         u(i) = i;
      else
         u(i) = z(j);
         j = j+1;
      end
  end
  
   u
end