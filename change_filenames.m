files =...
    dir( 'T:\Marino\Microscopy\150904\FL_eval\run_02\noiz_imgs\*.tif' );
cd('T:\Marino\Microscopy\150904\FL_eval\run_02\noiz_imgs');

for id = 1:length(files)
   
    [~, f] = fileparts(files(id).name);
    exprs = '[0-9]';
    inds = regexp(files(id).name, exprs);
%     filestr =...
%         'T:\Marino\Microscopy\150904\FL_eval\run_02\noiz_imgs\img488_';
    filestr = files(id).name;

%     num = str2double(files(id).name(inds)); 
%     filestr = strcat(filestr, sprintf('%04d.tif', num));
    newStr = strrep(filestr, '488', '488_');
    
    movefile(filestr, newStr);   
end

files =...
    dir( 'T:\Marino\Microscopy\150904\FL_eval\run_02\stripe_imgs\*.tif' );
cd('T:\Marino\Microscopy\150904\FL_eval\run_02\stripe_imgs')

for id = 1:length(files)
   
    [~, f] = fileparts(files(id).name);
    exprs = '[0-9]';
    inds = regexp(files(id).name, exprs);
%     filestr =...
%         'T:\Marino\Microscopy\150904\FL_eval\run_02\stripe_imgs\img488_';
    filestr = files(id).name;

%     num = str2double(files(id).name(inds)); 
%     filestr = strcat(filestr, sprintf('%04d.tif', num));
    newStr = strrep(filestr, '488_488', '488_');
    
    movefile(filestr, newStr);   
end
