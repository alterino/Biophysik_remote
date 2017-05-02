function [det_rate, false_rate, opt_eval] = generate_ROC( true_vec, false_vec, n_pts )
% GENERATE_ROC Returns vectors representing the false detection rates and
% detection rates for an ROC curve based on the input vectors with the
% number of points in the ROC specified by n_pts

det_rate = zeros( n_pts, 1 );
false_rate = zeros( n_pts, 1 );

min_err = inf;


if( mean( true_vec ) > mean( false_vec ) )
    thresh_vec = linspace( max(true_vec), min(true_vec)-1, n_pts );
    for i = 1:length(thresh_vec)
        det_rate(i) = length( find(true_vec > thresh_vec(i)) )/length(true_vec);
        false_rate(i) = length( find(false_vec > thresh_vec(i)) )/length(false_vec);
        if( ( (1-det_rate(i))+false_rate(i))/2 < min_err )
            min_err = ( (1-det_rate(i))+false_rate(i) )/2;
            opt_eval = [ thresh_vec(i), det_rate(i), false_rate(i) ];
        end
    end
else
    thresh_vec = linspace( min(true_vec), max(false_vec)+1, n_pts );
    for i = 1:length(thresh_vec)
        det_rate(i) = length( find(true_vec < thresh_vec(i)) )/length(true_vec);
        false_rate(i) = length( find(false_vec < thresh_vec(i)) )/length(false_vec);
        if( ( (1-det_rate(i))+false_rate(i) )/2 < min_err )
            min_err = ( (1-det_rate(i))+false_rate(i) )/2;
            opt_eval = [ thresh_vec(i), det_rate(i), false_rate(i) ];
        end
    end
    
end

end

