function response = CheckID(UserID)
  load('SignaturesData.mat');
  if any(Usernames(:)==UserID)
      response = 0;
  else
      response = 1;
  end
end