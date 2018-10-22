function [pStates,pSeq, fs, bs, s] = Classify_Data(seq,tr,e,varargin)
warning off;
numStates = size(tr,1);
checkTr = size(tr,2);
if checkTr ~= numStates
    
end



checkE  = size(e,1);
if checkE ~= numStates
   
end

numSymbols = size(e,2);


if nargin > 3
    okargs = {'symbols'};
    symbols = internal.stats.parseArgs(okargs, {''}, varargin{:});
    
    if ~isempty(symbols)
        numSymbolNames = numel(symbols);
        if ~isvector(symbols) || numSymbolNames ~= numSymbols
    
        end
        [~, seq]  = ismember(seq,symbols);
        if any(seq(:)==0)
       
        end
    end
end

if ~isnumeric(seq)
    
end
numEmissions = size(e,2);
if any(seq(:)<1) || any(seq(:)~=round(seq(:))) || any(seq(:)>numEmissions)
     
end



seq = [numSymbols+1, seq ];
L = length(seq);

fs = zeros(numStates,L);
fs(1,1) = 1; 
s = zeros(1,L);
s(1) = 1;
for count = 2:L
    for state = 1:numStates
        fs(state,count) = e(state,seq(count)) .* (sum(fs(:,count-1) .*tr(:,state)));
    end
  
    s(count) =  sum(fs(:,count));
    fs(:,count) =  fs(:,count)./s(count);
end


bs = ones(numStates,L);
for count = L-1:-1:1
    for state = 1:numStates
      bs(state,count) = (1/s(count+1)) * sum( tr(state,:)'.* bs(:,count+1) .* e(:,seq(count+1))); 
    end
end


pSeq = sum(log(s));
pStates = fs.*bs;

pStates(:,1) = [];


