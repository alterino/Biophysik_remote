% for i=0:testInfo.getLength - 1
%     if strcmpi(testInfo.item(i).getNodeName, 'Cycle Time')
%         phoneNumber = testInfo.item(i).getTextContent
%     end
% end

% client = loadOmero();
% session = client.createSession(user, password);
% client.enableKeepAlive(60);
% images = getImages(session, ids);
% client.closeSession();

% Raw Data access

if( ~exist( 'fluor_img', 'var' ) )
    fluor_img = imread( 'T:\Marino\Microscopy\170629\Fluor_405_170629_1100.tif' );
end


fluor_stack = img_2D_to_img_stack(fluor_img, [600 600] );

bw_stack = zeros( size( fluor_stack ) );
cc = cell( size(fluor_stack, 3), 1 );

figure(1)
for i = 1:size( fluor_stack, 3 )
    [bw_stack(:,:,i), cc{i}, img_stats(i)] = threshold_fluor_img( fluor_stack(:,:,i), 1000 );
    subplot(1,2,1), imshow(fluor_stack(:,:,i), []), subplot(1,2,2), imshow( bw_stack(:,:,i), [] )
end


