function bool = batch_test_func()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

figure
for i = 1:100
    if( mod(i,2)==0 )
        test = ones(100,100);
        imshow(test); drawnow
    else
        test = zeros(100,100);
        imshow(test); drawnow
    end
    pause(.1)
end
bool = 1;

