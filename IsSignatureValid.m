function result = IsSignatureValid(X)
load('NN1weights.mat');
pred = predict(Theta1, Theta2, X);
if pred==1
    result = 0;
else
    result = 1;
end