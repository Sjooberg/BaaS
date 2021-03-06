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

function RBF_Gamma=BSeuCallGammaI(S,K,T,r,sig)
% % ========================
% % Parameters for The Options
% % ========================
% 
% clear all; format long;
% S=[90, 100, 110]; %Stock price at time 0
% K=100; %Strike Price
% r=0.03; %Interest rate
% sig=0.15; %Volatility
% T=1; %Maturity

M=110; %Time Step
N=160; %Node
theta=0.5;
a=30; %interval [a,b]
b=2*K; %interval [a,b]
e=0.93*log(K);
f=1.06*log(K);%(11/10)*log(K);
if S>=101
    cg=0.66;
    ab=0.9;
else
    cg=0.63;
    ab=1;
end
% cg=0.63;
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

dt1=dt/65;
for i=1:65
    
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
   if mod(i,10)==0
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
 LN=length(S);
 RBF_Gamma=zeros(1,LN);
 for i=1:LN 
RBF_Gamma(1,i)=sum(lambda.*(((c.^2)./(sqrt(((x(1,i)-x1).*c).^2+1).^3))-(((c.^2).*(x(1,i)-x1))./(sqrt(((x(1,i)-x1).*c).^2+1))))/(S(1,i)^2));
 end
 end
% Gamma=[0.026971755100040 0.025609261020380 0.015975258690289];
% relerr=abs(Gamma-RBF_Gamma)./Gamma