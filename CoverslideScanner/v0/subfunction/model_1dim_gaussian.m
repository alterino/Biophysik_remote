function yhat = model_1dim_gaussian(theta,xdata)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 30.04.2014

%model of 1dim symmetric gaussian
%input:
%theta = [area std]
%xdata = [pos]

yhat = theta(1)/sqrt(2*pi)/theta(2)*...
    exp(-0.5*(xdata.^2)/theta(2)^2);
end %nested0