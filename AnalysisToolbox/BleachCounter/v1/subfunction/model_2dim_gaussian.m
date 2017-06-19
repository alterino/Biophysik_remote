function yhat = model_2dim_gaussian(theta,xdata)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 22.04.2014

%model of 2dim symmetric gaussian
%input:
%theta = [volume std]
%xdata = [pos_i pos_j]

yhat = theta(1)/2/pi/theta(2)^2*...
    exp(-0.5*(xdata(:,1).^2+xdata(:,2).^2)/theta(2)^2);
end %nested0