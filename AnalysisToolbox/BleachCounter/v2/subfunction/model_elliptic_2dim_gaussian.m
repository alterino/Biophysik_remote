function yhat = model_elliptic_2dim_gaussian(theta,xdata)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 22.04.2014
%modified 28.04.2014: Offset removed

%model of 2dim elliptic gaussian
%input:
%theta = [volume std_i std_j]
%xdata = [pos_i pos_j]

yhat = theta(1)/2/pi/theta(2)/theta(3)*...
    exp(-0.5*(xdata(:,1).^2/theta(2)^2+...
    xdata(:,2).^2/theta(3)^2));
end %nested0