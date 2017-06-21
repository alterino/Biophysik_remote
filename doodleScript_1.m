for i=0:testInfo.getLength - 1
    if strcmpi(testInfo.item(i).getNodeName, 'Cycle Time')
        phoneNumber = testInfo.item(i).getTextContent
    end
end