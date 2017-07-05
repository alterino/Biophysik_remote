for i = 1:size( fluor_stack, 3)
    
    img = im2double(fluor_stack(:,:,i));
    
    if( isempty( find( img > 0, 1) ) )
        continue
    end
    
   img_vec = img(:);
    
   figure(1), imshow( img, [] );
    
end



eval = evalclusters(img_vec(1:1e2:end), 'kmeans','gap','KList',[1:4])
























