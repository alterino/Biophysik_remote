function yhat = model_discrete_elliptic_2dim_gaussian(theta,xdata)
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

yhat = (erf((xdata(:,1)-0.5)/theta(2)/sqrt(2))-erf((xdata(:,1)+0.5)/theta(2)/sqrt(2))).*...
         (erf((xdata(:,2)-0.5)/theta(3)/sqrt(2))-erf((xdata(:,2)+0.5)/theta(3)/sqrt(2)))*...
         theta(1)/4;
end %nested0
