length1 = getLength( theNode.getChildNodes );

for i = 1:ans-1
name = testNode.getNodeName;

if( strcmp( name, 'net') )
   childLength = getLength( testNode.getChildNodes ); 
   childNode = testNode.getFirstChild; 
   
   for j = 1:childLength-1
        
   end
end

testNode = testNode.getNextSibling;
end