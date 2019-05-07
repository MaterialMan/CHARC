function CL = generatelattices(level)
%   A lattice is an ordered set in which any two elements have a least
%   upper bound and a greatest lower bound.
%
%   >generatelattices(n) 
%   This will generate all lattices between cardinality 4 and cardinality n 
%
%   WARNING: DO NOT PUT IN A LARGE VALUE FOR n. 11 is probably too big.
%
%   n should be an integer between 4 and 10
%   Up to size 9 will take a few minutes, size 10 may take several hours 
% 
%   folders will be created and each folder will contain an anaglyph image
%   and a text file that is a Formal Context that will generate the lattice.
%
%   Drawing pretty lattices automatically can be quite difficult, but some
%   of the images actually came out pretty nice. If you know of a good way
%   to generate good lattice pictures, feel free to share it
% Tim Hannan <hannan87@msn.com>
% October 2, 2011
X = 0;
CL = cell(0,0);
CL{1}=X;
n = 3;
while n<level
    NL = cell(0,0);
    for i=1:length(CL);
        C = children(CL{i});
        for j=1:length(C)
            if(~contains(NL,C{j}))
                len = length(NL);
                NL{len+1} = C{j};
            end
        end
    end
    n=n+1;
    makeimages(NL);
    CL = NL;
end
end
function C = children(x)
a = size(x,1);
C=cell(0,0);
z = x;
z(a+1,a+1) = 0;
C{1} = canonical(z);
v = zeros(1,a);
v(a) = 1;
while(~(all(v==0)))
    if(lac(x,v))
        y = child(x,v);
        if(~contains(C,y))
            len = length(C);
            C{len+1} = y;
        end
    end
    v = nextset(v);
end
end
function y = child(x,v)
a = length(v);
y = x;
y(a+1,a+1)=0;
for i=1:a
    if(v(i))
        y(a+1,i)=1;
        u = x(i,:);
        for j=1:a
            if(u(j))
                y(a+1,j) = 1;
            end
        end
    end
end
y = canonical(y);
end
function x = canonical(y)
x = y;
n = size(y,1);
p = perms(1:n);
for i=1:size(p,1)
    z = rearrange(y,p(i,:));
    x = smaller(x,z);
end
end
function b = contains(C,x)
b = false;
if(~isempty(C))
    for i=1:length(C)
        if(all(all(C{i}==x)))
            b = true;
        end
    end
end
end
function b = lac(x,v)
b = antichain(x,v);
if(b)
    u = filter(x,v);
    n = length(u);
    for i=1:n-1
        if(u(i))
            for j=i+1:n
                if(u(j))
                    if(~meetcondition(x,u,i,j));
                        b=false;
                        break;
                    end
                end
            end
            if(~b)
                break;
            end
        end
    end
end
end
function b = meetcondition(x,u,i,j)
b=false;
n=size(x,1);
if(x(i,j) || x(j,i))
    b = true;
elseif(~any(x(:,i) & x(:,j)))
    b = true;
else
    for k=1:n
        if(x(k,i) && x(k,j) && u(k))
            b = true;
            break;
        end
    end
end
end
function b = antichain(X,v)
n = length(v);
b = true;
for i=1:n-1
    if(v(i))
        for j=i+1:n
            if(v(j))
                if(X(i,j) || X(j,i))
                    b = false;
                    break;
                end
            end
        end
        if(~b)
            break;
        end
    end
end
end
function u = filter(X,v)
n = length(v);
u = v;
for i=1:n
    if(v(i))
        for j=1:n
            if(X(i,j))
                u(j) = 1;
            end
        end
    end
end
end
function Y = rearrange(X,v)
m = size(X,1);
Y=zeros(m);
for i=1:m
    for j=1:m
        if(X(i,j))
           Y(v(i),v(j))=1;
        end
    end
end
end
function v = nextset(u)
b = length(u);
for i=b:-1:1
    if(u(i)==1)
        u(i)=0;
        continue;        
    elseif(u(i)==0)
        u(i)=1;
        break;
    end
end
v=u;
end
function x = smaller(y,z)
a = size(y,1);
x=y;
for i=1:a
    if(all(y(i,:)==z(i,:)))
        continue;
    else
        for j=a:-1:1
            if(y(i,j)==z(i,j))
                continue;
            elseif(y(i,j)<=z(i,j));
                x=y;
                break;
            else
                x=z;
                break;
            end
        end
        break;
    end
end
end
function makeimages(C)
numimages = length(C);
f = figure('Visible','off');
n = size(C{1},2);
foldername = strcat(num2str(n+2),'ElementLattices');
mkdir(foldername);
for i=1:numimages
    filename = strcat(foldername,'/','Lattice',num2str(i));
    c=covers(C{i});
    y = makecontext(c,C{i});
    writecontext(y,filename);
    set(0,'CurrentFigure',f);
    clf(f);
    lattice3d(c,C{i});
    axis([-.8 .8 -.1 1.1]);
    axis off;
    print(f,'-dpng', filename);    
end
end
function y = makecontext(c,x)
m = size(x,1);
x = x + eye(m);
x = [[[x zeros(m,1)];ones(1,m+1);zeros(1,m+1)] ones(m+2,1)];
mi = zeros(1,m+2);
ji = zeros(1,m+2);
for i=1:m+2
    if(sum(c(:,2)==i)==1)
        ji(i)=1;
    end
    if(sum(c(:,1)==i)==1)
        mi(i)=1;
    end
end
for i=m+2:-1:1
    if(~mi(i))
        x(:,i)=[];
    end
    if(~ji(i))
        x(i,:)=[];
    end
end
y=x;
end
function c = covers(L)
a=size(L,1);
c=zeros(1,2);
for i=1:a
    for j=1:a
        if(L(i,j))
            cover = true;
            for k=1:a
                if(L(i,k) && L(k,j))
                    cover = false;
                    break;
                end
            end
            if (cover)
                c = [c;[i j]];
            end
        end
    end
end
for i=1:a
    if(sum(L(i,:))==0)
        c = [c;[i a+2]];
    end
    if(sum(L(:,i))==0)
        c = [c;[a+1 i]];
    end
end
c(1,:)=[];
end
function P = positions(covers)
n = length(unique(covers));
numcovers = size(covers,1);
uplengths = zeros(1,n);
downlengths = zeros(1,n);
v = n-1;
while(true)
    u=[];
    for i=1:length(v)
        for j=1:numcovers
            if(covers(j,1) == v(i))
                downlengths(covers(j,2))=downlengths(covers(j,1))+1;
                u = [u covers(j,2)];
            end
        end
    end 
    v = u;
    if unique(u) == n
        break;
    end
end
   
v = n;
while(true)
    u=[];
    for i=1:length(v)
        for j=1:numcovers
            if(covers(j,2) == v(i))
                uplengths(covers(j,1))=uplengths(covers(j,2))+1;
                u = [u covers(j,1)];
            end
        end
    end 
    v = u;
    if unique(u) == n-1
        break;
    end
end
I = zeros(n,1);
Z = zeros(n,1);
X = [rand(n-2,1)/10; 0; 0];
Y = [rand(n-2,1)/10; 0; 0];
for i=1:n
    I(i) = i;
    Z(i) = downlengths(i)/(downlengths(i)+uplengths(i));
end
heights = unique(Z);
for i=1:length(heights)
    h=heights(i);
    w = [];
    for j=1:length(Z)
        if(Z(j)==h)
            w = [w j];
        end
    end
    levelnum = length(w);
    if (levelnum > 1)
        angle = 2*pi/levelnum;
        for k = 1:levelnum
            X(w(k)) = cos(k*angle);
            Y(w(k)) = sin(k*angle);
        end
    end
end
P=[I X Y Z];
        
end
function D = dissimilarities(x,p)
a = size(x,1);
D = zeros(a);
for i=1:a-1
    for j=i+1:a         
        if(x(i,j) || x(j,i))
            d = abs(p(i,4)-p(j,4));
            D(i,j) = d;
            D(j,i) = d;
        else           
            ds = x(i,:)& x(j,:);
            us = x(:,i)& x(:,j);
            mh = 0;
            jh = 1;
            for k=1:a
                if(ds(k) && p(k,4) > mh)
                    mh = p(k,4);
                end
                if(us(k) && p(k,4) < jh)
                    jh = p(k,4);
                end
            end
            d = (jh-mh)/2;
            D(i,j) = d;
            D(j,i) = d;
        end        
    end
end
D(a+1,a+2) = 1;
D(a+2,a+1) = 1;
for i=1:a
    D(a+1,i) = p(i,4);
    D(1,a+1) = p(i,4);
    D(a+2,i) = 1-p(i,4);
    D(i,a+2) = 1-p(i,4);
end
end
function X = improve(P,D)
[a,b] = size(P);
Z=zeros(a,b);
for k=1:40
    for i=1:a-2    %top and bottom fixed
        F=[0 0 0 0];
        for j=1:a
            if (i~=j && dist(P(i,:),P(j,:))~=0)
                F=F+forcecontribution(P,D(i,j),i,j);
            else
                F=F+[0 0 0 0];
            end
        end
        Z(i,2)=F(1,2);
        Z(i,3)=F(1,3);
        %update horizontal coords
    end
    P=P+1/(2*a)*Z;    
end
X=P;
end
function d = dist(x,y)
d=sqrt((x(1,2)-y(1,2))^2+(x(1,3)-y(1,3))^2+(x(1,4)-y(1,4))^2);
end
function f = forcecontribution(P,m,i,j)
a=size(P,1);
R = zeros(1,3);
for k = 1:3
    R(1,k) = P(j,k+1)-P(i,k+1);
end
r=(1/dist(P(i,:),P(j,:)))*R*(dist(P(i,:),P(j,:))-m)/a;
f=zeros(1,4);
f(1,2:4)=r;
end
function lattice3d(C,R)
%makes a lattice diagram from a set of covering relations
P=positions(C);
D = dissimilarities(R,P);
P=improve(P,D);
P=straighten(P);
P=fatten(P);
x=camangle(P);
draw3dposet(C,P,x,1);
end
function P = straighten(A)
a = size(A,1);
shift = [0 A(a-1,2) A(a-1,3) 0];
shear = [0 A(a,2)-A(a-1,2) A(a,3)-A(a-1,3) 0];    
for i=1:a
    A(i,:) = A(i,:)-shift-A(i,4)*shear;
end
P=A;
end
function draw3dposet(A,B,x,alpha)
a = size(B,1);
c = size(A,1);
phi1=(x+alpha)*pi/180;
phi2=(x-alpha)*pi/180;
T1=[cos(phi1) -sin(phi1);sin(phi1) cos(phi1)];
T2=[cos(phi2) -sin(phi2);sin(phi2) cos(phi2)];
for i=1:a
    v=[B(i,2) B(i,3)]';
    u1=(T1*v-[.02 0]')';
    u2=(T2*v+[.02 0]')';
%     u1=(T1*v)';
%     u2=(T2*v)';
    B1(i,2)=u1(1);
    B1(i,3)=u1(2);
    B2(i,2)=u2(1);
    B2(i,3)=u2(2);
end
if(a>1)    
    hold on;
    P1=plot(B1(:,2),B(:,4),'c.');
    set(P1,'MarkerSize',30);
    P2=plot(B2(:,2),B(:,4),'r.');
    set(P2,'MarkerSize',30);
    x=zeros(2,1);
    y=zeros(2,1);
    for i=1:c
        x(1,1)=B1(A(i,1),2);
        x(2,1)=B1(A(i,2),2);
        y(1,1)=B(A(i,1),4);
        y(2,1)=B(A(i,2),4);
        plot(x,y,'linewidth',3,'color','c');
    end
    for i=1:c
        x(1,1)=B2(A(i,1),2);
        x(2,1)=B2(A(i,2),2);
        y(1,1)=B(A(i,1),4);
        y(2,1)=B(A(i,2),4);
        plot(x,y,'linewidth',3,'color','r');
    end
end
end
function writecontext(x,name)
fid = fopen(strcat(name,'.txt'), 'w');
for i=1:size(x,1)
    fprintf(fid, '%1.0f', x(i,:));
    fprintf(fid, '\r\n');
end
fclose(fid);
end
function x = camangle(P)
x=0;
n = size(P,1);
v = [0,0];
maxdist = 0;
for i=1:n-3
    for j=i+1:n-2
        d = sqrt((P(i,2)-P(j,2))^2+(P(i,3)-P(j,3))^2);
        if(d>maxdist)
            maxdist = d;
            v = [P(i,2)-P(j,2) P(i,3)-P(j,3)];
        end
    end
end
if(maxdist>0)
    x = (angle(v(1)+v(2)*i)-pi/13)*180/pi;
end
end
function Q = fatten(P)
Q = P;
n = size(P,1);
max = 0;
for i=1:n-2
    r = sqrt(P(i,2)^2+P(i,3)^2);
    if(r>max)
        max=r;
    end
end
if(max>0)
    Q = [P(:,1) P(:,2)*.5/max P(:,3)*.5/max P(:,4)];
end
end