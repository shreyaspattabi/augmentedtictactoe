%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is a Tic-Tac-Toe augmented reality gameplay algorithm created 
%by Mitch Larva and Shreyes Pattabiraman for ECE 415 project, Fall 2016.
%This algorithm uses Fast/Robust Template Matching algorithm created by
%Dirk-Jan Kroon and can be found here: http://bit.ly/2gd5K6E
%Make sure the the webcam you are using is listed first when you type the
%command webcamlist, otherwise you will have to reference it differently
%in line 14. Any questions can be sent to mlarva2@uic.edu or
%spattt2@uic.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;close all;clear;

%Get image
I = snapshot(webcam);
XXX=imread('x.jpg');
ISharp = imsharpen(I,'Radius',2,'Amount',1);
GR = rgb2gray(ISharp);
BW = edge(GR,'Sobel',[],'both');
se = strel('disk',5);
BW = imdilate(BW,se);
BW = imdilate(BW,se);
BW = imerode(BW,se);
BW = imerode(BW,se);
A=BW;
State = [-1 -1 -1 ;-1 -1 -1 ;-1 -1 -1];
gameend=0;
while gameend==0
prompt = 'Have you moved? Y/N [Y]: ';
str = input(prompt,'s');
if str == 'Y'
while gameend==0 && str =='Y'
    I = snapshot(webcam);
    ISharp = imsharpen(I,'Radius',2,'Amount',1);
    GR = rgb2gray(ISharp);
    BW = edge(GR,'Sobel',[],'both');
    se = strel('disk',5);
    BW = imdilate(BW,se);
    BW = imdilate(BW,se);
    BW = imerode(BW,se);
    BW = imerode(BW,se);
    [H,T,R] = hough(BW);
    P = houghpeaks(H,4);
    lines = houghlines(BW,T,R,P,'FillGap',500,'MinLength',100);
    figure, imshow(I), hold on
    max_len = 0;
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

        % Plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

        % Determine the endpoints of the longest line segment
        len = norm(lines(k).point1 - lines(k).point2);
        if ( len > max_len)
            max_len = len;
            xy_long = xy;
        end
    end
    %Figure out intersection points
    line1 = [lines(1).point1(1) lines(1).point1(2);lines(1).point2(1) lines(1).point2(2)]; 
    line2 = [lines(2).point1(1) lines(2).point1(2);lines(2).point2(1) lines(2).point2(2)];
    line3 = [lines(3).point1(1) lines(3).point1(2);lines(3).point2(1) lines(3).point2(2)];
    line4 = [lines(4).point1(1) lines(4).point1(2);lines(4).point2(1) lines(4).point2(2)];
    slope = @(line) (line(2,2) - line(1,2))/(line(2,1) - line(1,1));
    m1 = slope(line1);
    m2 = slope(line2);
    m3=slope(line3);
    m4=slope(line4);
    intercept = @(line,m) line(1,2) - m*line(1,1);
    b1=intercept(line1,m1);
    b2=intercept(line2,m2);
    b3=intercept(line3,m3);
    b4=intercept(line4,m4);
    xint12 =(b2-b1)/(m1-m2);
    yint12= m1*xint12 + b1;
    xint13=(b3-b1)/(m1-m3);
    yint13=m1*xint13+b1;
    xint14=(b4-b1)/(m1-m4);
    yint14=m1*xint14+b1;
    xint23=(b3-b2)/(m2-m3);
    yint23=m2*xint23+b2;
    xint24=(b4-b2)/(m2-m4);
    yint24=m2*xint24+b2;
    xint34=(b4-b3)/(m3-m4);
    yint34=m3*xint34+b3;
    imshow(I); hold on
    plot(xint12,yint12,'m*','markersize',8)
    plot(xint13,yint13,'m*','markersize',8)
    plot(xint14,yint14,'m*','markersize',8)
    plot(xint23,yint23,'m*','markersize',8)
    plot(xint24,yint24,'m*','markersize',8)
    plot(xint34,yint34,'m*','markersize',8)
    %Get the points the way we defined them (14 top left, 24 top right, 13
    %bottom left, 23 bottom right
    compare = [xint13,yint13;xint14,yint14;xint23,yint23;xint24,yint24];
    for i = 1 : 4
        total(i) = compare(i,1) + compare(i,2);
    end
    for i = 1: 4
        if min(total) == total(i)
            minloc = i;
        end
    end
    x14 = compare(minloc,1);
    y14 = compare(minloc,2);
    for i = 1: 4
        if max(total) == total(i)
            maxloc = i;
        end
    end
    x23 = compare(maxloc,1);
    y23 = compare(maxloc,2);
    compare1 = [0;0];
    j = 1;
    i = 1;
    while i < 5
        if i == minloc || i ==maxloc
        i = i + 1; 
        continue
        end    
    compare1(j) = compare(i,1);
    i = i + 1;
    j = j + 1;
    end
    x13 = min(compare1);
    x24 = max(compare1);
    compare1 = [0;0];
    j = 1;
    i = 1;
    while i < 5
        if i == minloc || i ==maxloc
           i = i + 1; 
           continue
        end    
    compare1(j) = compare(i,2);
    i = i + 1;
    j = j + 1;
    end  
    y13 = max(compare1);
    y24 = min(compare1);        
%Template Matching, Picture 4 = same picture but now with x move
% Find maximum response
    BW2 = edge(GR,'Sobel',[],'both');
    se = strel('disk',5);
    BW2 = imdilate(BW2,se);
    Idouble = im2double(BW2);
    % Template of X
    T=im2double(imbinarize(rgb2gray(XXX)));
    % Calculate SSD and NCC between Template and Image
    [I_SSD,I_NCC]=template_matching(T,Idouble);
    % Find maximum correspondence in I_SDD image
    [y,x]=find(I_SSD==max(I_SSD(:)));

    %Input users move
    Q1 = 1;Q2=2;Q3=3;Q4=4;Q5=5;Q6=6;Q7=7;Q8=8;Q9=9;
    if x<x14 && y<y14
        State(Q1) = 1;
    elseif x>x14 && x<x24 && y<y14
        State(Q4) = 1;
    elseif x>x24 && y<y24
        State(Q7) = 1;
    elseif x<x14 && y>y14 && y<y13
        State(Q2) = 1;
    elseif x>x14 && x<x24 && y>y14 && y<y23
        State(Q5) = 1;
    elseif x>x24 && y>y24 && y<y23
        State(Q8) = 1;
    elseif x<x13 && y>y13
        State(Q3) = 1;
    elseif x>x13 && x<x23 && y>y13
        State(Q6) = 1;
    elseif x>x23 && y>y13
        State(Q9) = 1;
    end

    %Get computer move
    compmove = 0;
    while compmove == 0
        rand = randi([1 9],1);
        if State(rand) == -1
            State(rand) = 0;
            compmove = 1;
        end
    end

    %Show computer move
    if rand == 1
        imshow(I); hold on
        plot(x14-100,y14-100,'bO','markersize',80)
    elseif rand == 2
        imshow(I); hold on
        plot(x14-100,y14+100,'bO','markersize',80)
    elseif rand == 3
        imshow(I); hold on
        plot(x13-100,y13+100,'bO','markersize',80)
    elseif rand == 4
        imshow(I); hold on
        plot(x14+100,y14-100,'bO','markersize',80)
    elseif rand == 5
        imshow(I); hold on
        plot(x14+100,y14+100,'bO','markersize',80)
    elseif rand == 6
        imshow(I); hold on
        plot(x13+100,y13+100,'bO','markersize',80)
    elseif rand == 7
        imshow(I); hold on
        plot(x24+100,y24-100,'bO','markersize',80)
    elseif rand == 8
        imshow(I); hold on
        plot(x24+100,y24+100,'bO','markersize',80)
    elseif rand == 9
        imshow(I); hold on
        plot(x23+100,y23+100,'bO','markersize',80)
    end

    %Whiteout User's move
    [maxy,maxx]=size(A);
    xx13 = round(x13);
    xx14 = round(x14);
    xx23 = round(x23);
    xx24 = round(x24);
    yy13 = round(y13);
    yy14 = round(y14);
    yy23 = round(y23);
    yy24 = round(y24);

    for i=1:9
        if State(i)==1
            if i == 1
                for i= 1: yy14
                    for j= 1: xx14
                    A(i,j) =1;
                    end 
                end
            end 
            if i== 2
                for i=yy14: yy13
                    for j= 1:xx14
                        A(i,j)=1;
                    end 
                end 
            end 
            if i== 3
                for i=yy13:maxy
                    for j=1:xx13
                        A(i,j)=1;
                    end 
                end 
            end 
            if i==4
                for i=1:yy14
                    for j= 1: xx13
                        A(i,j)=1;
                    end 
                end 
            end 
            if i==5
                for i=yy14:yy13
                    for j=xx14:xx24
                        A(i,j)=1;
                    end 
                end 
            end 
            if i==6 
                for i= yy13:maxy
                    for j= xx13:xx23
                        A(i,j)=1;
                    end 
                end 
            end
            if i==7
                for i=1:yy24
                    for j=xx24:maxx
                        A(i,j)=1;
                    end 
                end 
            end 
            if i==8
                for i=yy24:yy23
                    for j=xx24:maxx
                        A(i,j)=1;
                    end 
                end
            end 
            if i==9
                for i=yy23:maxy
                    for i=xx23:maxx
                        A(i,j)=1;
                    end 
                end 
            end 
        end 
    end
    for i=1:3
        if sum(State(:,i))==3
            gameend=1;
        elseif sum(State(i,:))==3
            gameend=1;
        elseif State(1)+State(5)+State(9)==3
            gameend=1;
        elseif State(7)+State(5)+State(3)==3
            gameend=1;
        elseif min(min(State))~=-1
            gameend=1;
        end 
    end
    str = 'N';
end
end
end