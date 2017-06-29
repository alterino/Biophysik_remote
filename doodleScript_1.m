% for i=0:testInfo.getLength - 1
%     if strcmpi(testInfo.item(i).getNodeName, 'Cycle Time')
%         phoneNumber = testInfo.item(i).getTextContent
%     end
% end

client = loadOmero();
session = client.createSession(user, password);
client.enableKeepAlive(60);
images = getImages(session, ids);
client.closeSession();