function x = get_free_ratio(c)
     c = c*100;
     if c<=15,        x = ceil(c);    x = x/100; return; end;
     if c>15&&c<=20,  x = 20;         x = x/100; return; end;
     if c>20&&c<=30,  x = 30;         x = x/100; return; end;
     if c>30&&c<=40,  x = 40;         x = x/100; return; end;
     if c>40&&c<=50,  x = 50;         x = x/100; return; end;
     if c>50&&c<=60,  x = 60;         x = x/100; return; end;
     if c>60&&c<=70,  x = 70;         x = x/100; return; end;
     if c>70&&c<=80,  x = 80;         x = x/100; return; end;
     if c>80,         x = 100;        x = x/100; return; end;
  
end