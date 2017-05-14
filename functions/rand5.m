% function [rand_5, num] = rand5()
function out = rand5()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% binary = zeros(1,3);
% 
% for i = 1:3
%     [binary(i), num(i)] = generate_binary_rand5();
% end
% 
% rand_5 = bi2de(binary);
% if( rand_5 > 4 )
%     rand_5 = rand5();
% end

out = randi(7);

if( out > 5 )
    out = rand5();
end