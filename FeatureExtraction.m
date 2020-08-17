function[featureVector] = Features(rgb)
%%%%%%%%%%%%%%%%%%%%  PRE-PROCESSING  %%%%%%%%%%%%%%%%%%%%%%%%%%%
[rows, columns, hint] = size(rgb);
if hint>1
    gray = rgb2gray(rgb);
else
    gray = rgb;
end
thinned = Preprocessing(rgb);
st = regionprops(thinned, 'BoundingBox' );
thisBB = st(1).BoundingBox;
thinned = thinned(round(thisBB(2)):thisBB(4),round(thisBB(1)):thisBB(3));
%%%%%%%%%%%%%%%%%%% FEATURE EXTRACTION %%%%%%%%%%%%%%%%%%%%%%%%%%
[rows,cols]=size(thinned);
featureVector =[];
% Aspect Ratio
AspRatio = thisBB(3)/thisBB(4);  %AspRatio
featureVector =[featureVector;AspRatio];
% Max Horizontal and Max verticl Histogram
[r,rloc]=max(sum(thinned==0,2));    %rloc
[c,cloc]=max(sum(thinned==0,1));    %cloc
featureVector = [featureVector;rloc;cloc];
% center of mass of part1
mid=round(cols/2);
thinned1=thinned(:,1:mid);
labeledImage1 = bwlabel(thinned1);
measurements1 = regionprops(labeledImage1, thinned1, 'WeightedCentroid');
centerOfMass1 = measurements1.WeightedCentroid;
lX = centerOfMass1(1);              %lX
lY = centerOfMass1(2);              %lY
featureVector = [featureVector;lX;lY];
% center of mass of part2
thinned2=thinned(:,mid+1:end);
labeledImage2 = bwlabel(thinned2);
measurements2 = regionprops(labeledImage2, thinned2, 'WeightedCentroid');
centerOfMass2 = measurements2.WeightedCentroid;
rX = centerOfMass2(1);               %rX
rY = centerOfMass2(2);               %rY
featureVector = [featureVector;rX;rY];
% Normalized area
AreaOfSignature = bwarea(~thinned);
TotArea = rows*cols;
NMarea = AreaOfSignature/TotArea;    %NMarea
featureVector = [featureVector;NMarea];
% Tri Normalized Areas
cutoff = round(cols/3);
part1 = thinned(:,1:cutoff);
part2 = thinned(:,cutoff+1:2*cutoff);
part3 = thinned(:,2*cutoff+1:end);
[row1,col1]=size(part1);
[row2,col2]=size(part2);
[row3,col3]=size(part3);
AreaOfSignature1 = bwarea(~part1);
TotArea1 = row1*col1;
NMarea1 = AreaOfSignature1/TotArea1;  %NMarea1
featureVector = [featureVector;NMarea1];
AreaOfSignature2 = bwarea(~part2);
TotArea2 = row2*col2;
NMarea2 = AreaOfSignature2/TotArea2;  %NMarea2
featureVector = [featureVector;NMarea2];
AreaOfSignature3 = bwarea(~part3);
TotArea3 = row3*col3;
NMarea3 = AreaOfSignature3/TotArea3;  %NMarea3
featureVector = [featureVector;NMarea3];
% Six fold surface feature
%left part
labeledImage_left = bwlabel(part1);
props_left = regionprops(labeledImage_left, part1, 'WeightedCentroid');
COM_left = props_left.WeightedCentroid;
LX = round(COM_left(1));
LY = round(COM_left(2));
top_left = part1(1:LY,:);
[rtL,ctL]=size(top_left);
bottom_left = part1(LY+1:end,:);
[rbL,cbL]=size(bottom_left);
topLeft_sign = bwarea(~top_left);
topLeft_Tot = rtL*ctL;
topLeft_NMA = topLeft_sign/topLeft_Tot;    %topLeft_NMA
featureVector = [featureVector;topLeft_NMA];
bottomLeft_sign = bwarea(~bottom_left);
bottomLeft_Tot = rbL*cbL;
bottomLeft_NMA = bottomLeft_sign/bottomLeft_Tot;  %bottomLeft_NMA
featureVector = [featureVector;bottomLeft_NMA];
%middle part
labeledImage_middle = bwlabel(part2);
props_middle = regionprops(labeledImage_middle, part2, 'WeightedCentroid');
COM_middle = props_middle.WeightedCentroid;
MX = round(COM_middle(1));
MY = round(COM_middle(2));
top_middle = part2(1:MY,:);
[rtM,ctM]=size(top_middle);
bottom_middle = part2(MY+1:end,:);
[rbM,cbM]=size(bottom_middle);
topMiddle_sign = bwarea(~top_middle);
topMiddle_Tot = rtM*ctM;
topMiddle_NMA = topMiddle_sign/topMiddle_Tot;    %topMiddle_NMA
featureVector = [featureVector;topMiddle_NMA];
bottomMiddle_sign = bwarea(~bottom_middle);
bottomMiddle_Tot = rbM*cbM;
bottomMiddle_NMA = bottomMiddle_sign/bottomMiddle_Tot;  %bottomMiddle_NMA
featureVector = [featureVector;bottomMiddle_NMA];
%right part
labeledImage_right = bwlabel(part3);
props_right = regionprops(labeledImage_right, part3, 'WeightedCentroid');
COM_right = props_right.WeightedCentroid;
RX = round(COM_right(1));
RY = round(COM_right(2));
top_right = part3(1:RY,:);
[rtR,ctR] = size(top_right);
bottom_right = part3(RY+1:end,:);
[rbR,cbR] = size(bottom_right);
topRight_sign = bwarea(~top_right);
topRight_Tot = rtR*ctR;
topRight_NMA = topRight_sign/topRight_Tot;    %topRight_NMA
featureVector = [featureVector;topRight_NMA];
bottomRight_sign = bwarea(~bottom_right);
bottomRight_Tot = rbR*cbR;
bottomRight_NMA = bottomRight_sign/bottomRight_Tot;  %bottomRight_NMA
featureVector =[featureVector;bottomRight_NMA];
% ratio of Adjacency Columns
lT=0;
lB=0;
for i=1:cols
    arr = thinned(:,i);
    k = find(arr==0);
    if length(k)>0
        if length(k)==1 && k(1)==rows
            lT=lT+k(1);
        else
            if length(k)==1 && k(1)==0
                lB = lB+(rows-k(end));
            else
                lT=lT+k(1);
                lB = lB+(rows-k(end));
            end
        end
    end
end
AdjRatio = (lT/lB)*NMarea;      %AdjRatio
featureVector = [featureVector;AdjRatio];
stats = regionprops(thinned,'Eccentricity','Circularity','Orientation','Solidity','EulerNumber','BoundingBox','Area');
Max= 0;
INDEX = 1;
for m=1:length(stats)
    AREA = stats(m).Area;
    if AREA>Max
        INDEX = m;
        Max = AREA;
    end
end
stats = stats(INDEX);
featureVector = [featureVector;stats.Eccentricity];
featureVector = [featureVector;stats.Circularity];
featureVector = [featureVector;stats.Orientation];
featureVector = [featureVector;stats.Solidity];
featureVector = [featureVector;stats.EulerNumber];
Entropy = entropy(gray);
featureVector = [featureVector;Entropy];
Mean = mean2(thinned);
featureVector = [featureVector;Mean];
Std = std2(thinned);
featureVector = [featureVector;Std];
idx = thinned==0;
hist = sum(idx,1);
n = length(hist);
hist_dash = mean(hist);
s = std(hist);
summation1=0;
summation2=0;
for i=1:n
    summation1 = summation1+(hist(i)-hist_dash)^3;
    summation2 = summation2+(hist(i)-hist_dash)^4;
end
skewness = (summation1/n)/(s^3);
kurtosis = (summation2/n)/(s^4);
featureVector = [featureVector;skewness;kurtosis];
featureVector = normalize(featureVector);
end