function chker = varlist2(X,Y,Z,varargin)
   fprintf('Total number of inputs = %d\n',nargin);
   chker = varargin;

   nVarargs = length(varargin);
   fprintf('Inputs in varargin(%d):\n',nVarargs)
   for k = 1:nVarargs
      fprintf('   %d\n', varargin{k})
   end
   
end