function Return = main(UserID,image)
response = CheckID(UserID);
if response==1
    Return = 'Please do sign up';
else
    Features = FeatureExtraction(image);
    X = Features';
    result = IsSignatureValid(X);
    if result==1
        Return = 'Not accepted';
    else
        match = MatchUserID(X',UserID);
        if match ~= 1
            Return = 'Not accepted, please do try again';
        else
            Return = 'Accepted';
        end
    end
end