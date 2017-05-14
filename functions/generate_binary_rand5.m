function [binary_out, temp] = generate_binary_rand5()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    temp = randi(7);
    if( temp < 7 )
        binary_out = (temp > 3);
    else
        binary_out = generate_binary_rand5();
    end
        


end

