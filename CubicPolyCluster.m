data = xlsread('allsite.xls','sheet1','E2:G213');
y = data(:,3); %Re
x1 = data(:,1)/10;  % Temperature
x2 = data(:,2)/5; %Precipitation
p1 = 128/212; % Initial value for pi's
p2 = 84/212;
%b1 = [-0.41, 1.95]'; % initial value for beta1
%b2 = [-18.1, 1.579]'; % initial value for beta2

x11=[ones(size(y)), x1,x1.^2];
x22 = [ones(size(y)),x2,x2.^2];

x10 = x11(129:212,:);
x20 = x22(1:128,:);
b1= inv(x10'*x10)*x10'*y(129:212)
b2= inv(x20'*x20)*x20'*y(1:128)


e1 = y-x11*b1;
e2 = y-x22*b2;
s1 = mean(e1(129:212).^2);
s2 = mean(e2(1:128).^2);
 

    t1 = exp(-e1.^2/2/s1)/sqrt(s1);
    t2 = exp(-e2.^2/2/s2)/sqrt(s2);
    w1 = p1*t1./(p1*t1+p2*t2);
    w2 = 1-w1;
    p1 = mean(w1);
    p2 = 1-p1;

 
step=0;
eps=10^(-10);
delta=1;

while (step<100)&(delta>eps);
    step=step+1;
    b10 = inv(x11'*diag(w1)*x11)*x11'*diag(w1)*y;
    b20 = inv(x22'*diag(w2)*x22)*x22'*diag(w2)*y;
    
    delta = max([max(abs(b10-b1)),max(abs(b20-b2))]);
    b1 = b10;
    b2 = b20;
    e1 = y-x11*b1;
    e2 = y-x22*b2;
    s1 = sum(w1.*(e1.^2))/sum(w1); 
    s2 = sum(w2.*(e2.^2))/sum(w2); 
    t1 = exp(-e1.^2/2/s1)/sqrt(s1);
    t2 = exp(-e2.^2/2/s2)/sqrt(s2);
    w1 = p1*t1./(p1*t1+p2*t2);
    w2 = 1-w1;
    p1 = mean(w1);
    p2 = 1-p1;
    
end;
 
sheet='sheet4';
output=[(w1>0.5), w1,(w2>0.5), w2]

xlswrite('outupdated.xls',output,sheet,'L2:O213');

output=[[1:212]',(w1>0.95), w1,(w2>0.95), w2]

output=[(w1>0.95), w1,(w2>0.95), w2]

xlswrite('outupdated.xls',output,sheet,'P2:S213');
