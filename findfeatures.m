function [out] = findfeatures(entry)
global wavelength
[C,S] = wavedec2(double(entry),3,'coif1');
dimension = S(1,:);
dimx = dimension(1);
dimy = dimension(2);
v = C(1:dimx*dimy);
wavelength = length(v);
out{1} = v(:);
%
function [out] = ann_face_matching(features)
global wavelength
load('face_database.dat','-mat');
P = zeros(wavelength,features_size);
T = zeros(max_class-1,features_size);
for ii=1:features_size
 v = features_data{ii,1};
 v = v{1};
 v = v(:);
 P(:,ii) = v;
 pos = features_data{ii,2}; 
 for jj=1:(max_class-1)
 if jj==pos
 T(jj,ii) = 1;
 else
 T(jj,ii) = -1;
 end
 end
end
input_vector = features{1};
%Normalization
for ii=1:wavelength
 v = P(ii,:);
 v = v(:);
 bii = max([v;1]);
 aii = min([v;-1]);
 P(ii,:) = 2*(P(ii,:)-aii)/(bii-aii)-1;
 input_vector(ii) = 2*(input_vector(ii)-aii)/(bii-aii)-1;
end
[net] = createnn(P,T);
[valmax,posmax] = max(sim(net,input_vector));
out = posmax;