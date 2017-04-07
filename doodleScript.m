temp_mu = zeros( length( gmm_vec ), 3 );
temp_std = zeros( length( gmm_vec ), 3 );

for i = 1:length( gmm_vec )
    temp_gmm = gmm_vec{i};
    temp_mu(i,:) = sort(temp_gmm.mu);
    temp_std(i,:) = sort(temp_gmm.Sigma);
end



figure(1), plot( temp_mu(:,1), temp_std(:,1), 'b.', 'MarkerSize', 20 )
xlabel('\mu'), ylabel('\sigma'), grid on
figure(2), plot( temp_mu(:,2), temp_std(:,2), 'g.', 'MarkerSize', 20 )
xlabel('\mu'), ylabel('\sigma'), grid on
figure(3), plot( temp_mu(:,3), temp_std(:,3), 'r.', 'MarkerSize', 20 )
xlabel('\mu'), ylabel('\sigma'), grid on



% dir_str = 'T:\Marino\presentation_files\wind*';
%
% img_dir = dir( dir_str );
%
% bw_files = [];
% ent_files = [];
% raw_files = [];
%
% for i = 1:length( img_dir )
%
%     temp = img_dir(i).name;
%
%     if( ~isempty( strfind( temp, 'bw' ) ) )
%         bw_files{ length(bw_files)+1 } = temp;
%     elseif( ~isempty( strfind( temp, 'ent' ) ) )
%         ent_files{ length(ent_files)+1 } = temp;
%     elseif( ~isempty( strfind( temp, 'raw' ) ) && length(raw_files) < 8 )
%         raw_files{ length(raw_files)+1 } = temp;
%     end
%
%     filenames{i} = img_dir(i).name;
%
% end
%
% bw_files = bw_files';
% ent_files = ent_files';
% raw_files = raw_files';
% pic_idx = zeros( length( raw_files ), 1 );
% wind_idx = zeros( length( raw_files ), 1 );
%
% for i = 1:length( ent_files )
%     temp_str = ent_files{i};
%     pic_idx(i) =  str2double( temp_str(end-9:end-8) );
%     wind_idx(i) =  str2double( temp_str(6:7) );
% end
%
% pic_idx = unique( pic_idx );
% wind_idx = unique( wind_idx );
%
% wind_cnt = length( wind_idx );
% pic_cnt = length( pic_idx );
%
% img_files_sorted = cell( length( pic_idx ), 1 );
% temp_img_file_str = cell( length(pic_idx), 1 );
%
% imgs_cell = cell( pic_cnt, 1 );
%
% filenames_cmp = [ ent_files, bw_files ];
% raw_files = unique( raw_files );
% file_dir = 'T:\Marino\presentation_files\';
%
% for i = 1:length( raw_files )
%
%     temp = raw_files{i};
%     temp_pic_idx = str2double( temp(end-9:end-8) );
%     %     temp_wind_idx = str2double( temp(6:7) );
%
%     %     temp_img_set = imgs_cell{temp_wind_idx};
%
%     %     if( isempty( temp_img_set ) )
%     temp_img_set = zeros( 600, 600, length( wind_idx + 1 ), 'double' );
%     %     end
%
%     %     if( isempty( find( temp_img_set(:,:,1) > 0, 1 ) ) )
%     temp_img_set(:,:,1) = im2double( imread( strcat( file_dir , temp ) ) );
%     %     end
%
%     img_stack_idx = 1;
%     for j = 1:size( filenames_cmp, 1 )
%
%         %         temp_ent_str = filenames_cmp{j,1};
%         temp_bw_str = filenames_cmp{j,2};
%
%         %         if( strfind( ent_str, num2str(temp_pic_idx) ) == 19 )
%         %             temp_wind_idx = str2double( ent_str(6:7) );
%         %             temp_wind_idx = find( wind_idx == temp_wind_idx ) + 1;
%         %             temp_img_set(:,:,temp_wind_idx) =  im2double( imread( strcat( file_dir , ent_str ) ) );
%         %         end
%
%         if( strfind( temp_bw_str, num2str(temp_pic_idx) ) == 19 )
%             temp_wind_idx = str2double( temp_bw_str(6:7) );
%             temp_wind_idx = find( wind_idx == temp_wind_idx ) + 1;
%             temp_img_set(:,:,temp_wind_idx) =  im2double( imread( strcat( file_dir , temp_bw_str ) ) );
%         end
%
%     end
%
%     imgs_cell{ pic_idx == temp_pic_idx } = temp_img_set;
%
%
% end
%
% clear temp* *idx
%
% for i = 1:length( imgs_cell )
%
%     img_stack = imgs_cell{i};
%     figure(i)
%     for j = 1:size( img_stack, 3 )
%         subplot( 2,4,j ), imshow( img_stack(:,:,j) );
%     end
% end
%
%
