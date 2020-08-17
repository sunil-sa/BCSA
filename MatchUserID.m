function res = MatchUserID(A,UserID)
load('SignaturesData.mat');
dist = bsxfun(@minus, X, A);
dist2 = sqrt(sum(dist.*dist));
[mindist, column] = min(dist2);
pred = column;
res = Usernames(pred,:)==UserID;
end