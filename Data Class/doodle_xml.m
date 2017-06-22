% xmlfile = fullfile(matlabroot, 'toolbox/matlab/general/info.xml');
% xDoc = xmlread(xmlfile);
% xmlwrite(xDoc)

docNode = com.mathworks.xml.XMLUtils.createDocument('AddressBook');
xmlwrite(docNode)

entry_node = docNode.createElement('Entry');
docNode.getDocumentElement.appendChild(entry_node);
xmlwrite(docNode)

name_node = docNode.createElement('Name');
name_text = docNode.createTextNode('Friendly J. Mathworker');
name_node.appendChild(name_text);
entry_node.appendChild(name_node);

phone_number_node = docNode.createElement('PhoneNumber');
phone_number_text = docNode.createTextNode('(508) 647-7000');
phone_number_node.appendChild(phone_number_text);
entry_node.appendChild(phone_number_node);

xmlwrite(docNode)

address_node = docNode.createElement('Address');
address_node.setTextContent('3 Apple Hill Dr, Natick MA')
% set an attribute directly
address_node.setAttribute('type','work');

entry_node.appendChild(address_node);
% address_node.setAttribute('hasZip','no');

% or create the attribute as a node
has_zip_attribute = docNode.createAttribute('hasZip');
has_zip_attribute.setNodeValue('no');
address_node.setAttributeNode(has_zip_attribute);

xmlwrite(docNode)

% Get the "AddressBook" node
addressBookNode = docNode.getDocumentElement;
% Get all the "Entry" nodes
entries = addressBookNode.getChildNodes;
% Get the first "Entry"'s children
% Remember that java arrays are zero-based
friendlyInfo = entries.item(0).getChildNodes;
% Iterate over the nodes to find the "PhoneNumber"
% once there are no more siblinings, "node" will be empty
node = friendlyInfo.getFirstChild;
while ~isempty(node)
    if strcmpi(node.getNodeName, 'PhoneNumber')
        break;
    else
        node = node.getNextSibling;
    end
end
phoneNumber = node.getTextContent

for i=0:friendlyInfo.getLength - 1
    if strcmpi(friendlyInfo.item(i).getTagName, 'PhoneNumber')
        phoneNumber = friendlyInfo.item(i).getTextContent
    end
end

phoneNumber = friendlyInfo.getElementsByTagName('PhoneNumber').item(0).getTextContent