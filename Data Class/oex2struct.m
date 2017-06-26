function [ s ] = oex2struct( file )
%Convert xml file into a MATLAB structure
% [ s ] = oex2struct( file )
%
% A file containing:
% <XMLname attrib1="Some value">
%   <Element>Some text</Element>
%   <DifferentElement attrib2="2">Some more text</Element>
%   <DifferentElement attrib3="2" attrib4="1">Even more text</DifferentElement>
% </XMLname>
%
% Will produce:
% s.XMLname.Attributes.attrib1 = "Some value";
% s.XMLname.Element.Text = "Some text";
% s.XMLname.DifferentElement{1}.Attributes.attrib2 = "2";
% s.XMLname.DifferentElement{1}.Text = "Some more text";
% s.XMLname.DifferentElement{2}.Attributes.attrib3 = "2";
% s.XMLname.DifferentElement{2}.Attributes.attrib4 = "1";
% s.XMLname.DifferentElement{2}.Text = "Even more text";
%
% Please note that the following characters are substituted
% '-' by '_dash_', ':' by '_colon_' and '.' by '_dot_'
%
% Written by W. Falkena, ASTI, TUDelft, 21-08-2010
% Attribute parsing speed increased by 40% by A. Wanner, 14-6-2011
% Added CDATA support by I. Smirnov, 20-3-2012
%
% Modified by X. Mo, University of Wisconsin, 12-5-2012

if (nargin < 1)
    clc;
    help xml2struct
    return
end

if isa(file, 'org.apache.xerces.dom.DeferredDocumentImpl') || isa(file, 'org.apache.xerces.dom.DeferredElementImpl')
    % input is a java xml object
    xDoc = file;
else
    %check for existance
    if (exist(file,'file') == 0)
        %Perhaps the xml extension was omitted from the file name. Add the
        %extension and try again.
        if (isempty(strfind(file,'.xml')))
            file = [file '.xml'];
        end
        
        if (exist(file,'file') == 0)
            error(['The file ' file ' could not be found']);
        end
    end
    %read the xml file
    xDoc = xmlread(file);
end

%parse xDoc into a MATLAB structure

expPlanNode = xDoc.getFirstChild;

if(~strcmp(expPlanNode.getTagName, 'expPlan'))
    error('highest node not correct tag "expPlan".')
end

if hasChildNodes(expPlanNode)
    childNode = getFirstChild(expPlanNode);
else
    error('expPlanNode has no children')
end
%         numChildNodes = getLength(childNodes);

while( ~strcmp( childNode.getNodeName, 'net' ) )
    childNode = childNode.getNextSibling;
end
netNode = childNode;
s = parseNode(netNode);

end

% ----- Subfunction parseChildNodes -----
function nodeStruct = parseNode(theNode)
% Recurse over node children.

childNodes = getChildNodes(theNode);
numChildNodes = getLength(childNodes);

if( strcmp( theNode.getNodeName, 'edges' ) )
    fprintf('debug placeholder\n')
end

for count = 1:numChildNodes
    theChild = item(childNodes,count-1);
    %     [text,name,attr,childs,textflag] = getNodeData(theChild);
    child_name = theChild.getNodeName;
    if( strfind( child_name, '#' ) == 1 ) % checking if first character is '#'
        continue
    end
    
    if( strcmp( child_name, 'attribute' ) )
        [att_name, type, val] = parseAttribute(theChild);
        nodeStruct.( strrep(att_name, ' ', '_') ).type = type;
        nodeStruct.( strrep(att_name, ' ', '_') ).val = val;
    else
        if( theChild.hasAttribute('name') )
            child_name = char( theChild.getAttribute('name') );
        else
            child_name = char( theChild.getNodeName );
        end
        child_node_struct = parseNode(theChild);
        nodeStruct.(strrep(child_name, ' ', '_')) = child_node_struct;
    end
end

if( ~exist( 'nodeStruct', 'var' ) )
    nodeStruct = [];
%     warning('node structure is empty')
end

end

% ----- Subfunction parseAttributes -----
function [name, type, val] = parseAttribute(theNode)
% Create attributes structure.

name = []; type = []; val = [];

try
    name = char( theNode.getAttribute('name') );
catch
    error('could not find node name')
end
childNodes = getChildNodes(theNode);
numChildNodes = getLength(childNodes);

for count = 1:numChildNodes
    theChild = item(childNodes,count-1);
    child_name = theChild.getNodeName;
    if( strfind( child_name, '#' ) == 1 ) % checking if first character is '#'
        continue
    else
        try
            type = char( theChild.getNodeName );
            val = theChild.getAttribute('val');
        catch
            if(isempty(type))
                warning('could not find variable type');
            end
            if(isempty(val))
                warning('could not find value');
            end
        end
    end
    
end


end