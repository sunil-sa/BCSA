clear all
clc
imds=imageDatastore('NormalTrain','IncludeSubfolders',1,'LabelSource','foldernames');
imagTot=length(imds.Files);
X=[];
y=[];
for i=1:imagTot
%reading the image
rgb=readimage(imds,i);
NormalFeatures = FeatureExtraction(rgb);
X = [X,NormalFeatures];
y=[y;1];
end
imds1=imageDatastore('ForgedTrain','IncludeSubfolders',1,'LabelSource','foldernames');
imagTot1=length(imds1.Files);
for i=1:imagTot1
%reading the image
rgb1=readimage(imds1,i);
FraudFeatures = FeatureExtraction(rgb1);
X = [X,FraudFeatures];
y=[y;2];
end
X=X';
input_layer_size  = size(X,2);  
hidden_layer_size = 15; 
num_labels = 2;
initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
initial_Theta2 = randInitializeWeights(hidden_layer_size, num_labels);
initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];
options = optimset('MaxIter', 100);
lambda = 1;
costFunction = @(p) nnCostFunction(p, input_layer_size, hidden_layer_size, ...
                                   num_labels, X, y, lambda);
[nn_params, cost] = fmincg(costFunction, initial_nn_params, options);
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));
pred = predict(Theta1, Theta2, X);
fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y)) * 100);
save('NN1weights','Theta1','Theta2');