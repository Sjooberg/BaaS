 %Copyright (C) 2015 Jeremy Levesley

    %This file is part of BENCHOP.
    %BENCHOP is free software: you can redistribute it and/or modify
    %it under the terms of the GNU General Public License as published by
    %the Free Software Foundation, either version 3 of the License, or
    %(at your option) any later version.

    %BENCHOP is distributed in the hope that it will be useful,
    %but WITHOUT ANY WARRANTY; without even the implied warranty of
    %MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %GNU General Public License for more details.

    %You should have received a copy of the GNU General Public License
    %along with BENCHOP. If not, see <http://www.gnu.org/licenses/>.

function RBF_Price=BSeuCallUI(S,K,T,r,sig)
% % ========================
% % Parameters for The Options
% % ========================
%  
% S=90; %Stock price at time 0
% K=100; %Strike Price
% r=0.03; %Interest rate
% sig=0.15; %Volatility
% T=1; %Maturity

M=80; %Time Step
N=160; %Node
theta=0.5;
a=30; %interval [a,b]
b=2*K; %interval [a,b]
e=0.93*log(K);
f=1.05*log(K);
cg=0.66;
if S==100
    ab=0.8;
else
    ab=1;
end
err=1e-2; % error setting 
err = [err/ab err/20];% redefine error (error indicator)
dt=T/M;%Time step
x=log(S);
ksi=zeros(N,1);%define the set of nodes form ksi_1 to ksi_N
for i=1:N
    ksi(i)=(i-1)*((log(b)-log(a))/(N-1))+log(a);
end

maxdis=2*((log(b)-log(a))/(59));% Max distance between each point


 g=@(ksi) max(exp(ksi)-K,0);% The payoff of options


x1=ksi;

[x1,c,u0]=coarserefine3(g,x1,err,cg,maxdis,e,f);

u0(1)=0;
u0(end)=K;

dt1=dt/45;
for i=1:45
    
   tn=dt+i*dt1;
   
   N=length(x1);
   dx=diff(x1);
   c=cg*min([Inf;1./dx],[1./dx;Inf]);
   [Phi,Phi_1,Phi_2]=deal(zeros(N));
   for j=1:N
    [Phi(:,j),Phi_1(:,j),Phi_2(:,j)]=mq(x1,x1(j),c(j));
   end

   I=eye(N,N);
  
   P=I*r-0.5*(sig^2)*(Phi\Phi_2)-(r-0.5*(sig^2))*(Phi\Phi_1); 
   H=I+dt1*(1-theta)*P;
   G=I-dt1*theta*P;
   lambda=Phi\u0;
   lambda=H\G*lambda;
   u0=Phi*lambda;
   lambda1=Phi\eye(N);
   
   [x1,c,u0]=coarserefine1(@(xp)predictor(xp,x1,u0,lambda1,c),x1,err,cg,maxdis,e,f);
   
   
   nu=u0; 
   
        
 
   
         nu(1)=0;
         nu(end)=b-exp(-r*tn)*K;
   
    u0=nu;


end
 

for i=3:M+1
    
   tn=i*dt;
  
   N=length(x1);
   dx=diff(x1);
   c=cg*min([Inf;1./dx],[1./dx;Inf]);
   [Phi,Phi_1,Phi_2]=deal(zeros(N));
   for j=1:N
    [Phi(:,j),Phi_1(:,j),Phi_2(:,j)]=mq(x1,x1(j),c(j));
   end

   I=eye(N,N);
  
   P=I*r-0.5*(sig^2)*(Phi\Phi_2)-(r-0.5*(sig^2))*(Phi\Phi_1); 
   H=I+dt*(1-theta)*P;
   G=I-dt*theta*P;
   lambda=Phi\u0;
   lambda=H\G*lambda;
   u0=Phi*lambda;
   lambda1=Phi\eye(N);
   if mod(i,20)==0
   [x1,c,u0]=coarserefine1(@(xp)predictor(xp,x1,u0,lambda1,c),x1,err,cg,maxdis,e,f);
   end
   
   nu=u0; 

         nu(1)=0;
         nu(end)=b-exp(-r*tn)*K;
 
    u0=nu;

end


   N=length(x1);

   [Phi,Phi_1,Phi_2]=deal(zeros(N));
   for j=1:N
    [Phi(:,j),Phi_1(:,j),Phi_2(:,j)]=mq(x1,x1(j),c(j));
   end
  
 lambda=Phi\u0;
RBF_Price=sum(lambda.*sqrt(((x-x1).*c).^2+1));
end

