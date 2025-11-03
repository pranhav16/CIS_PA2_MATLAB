%find_transformation.m
% author: luiza
% this function computes the transformation matrix R and translation vector t
% for point set registration using SVD
function [R,t] = find_transformation(P, Q)
% Map P -> Q with Q ≈ R*P + t
% P, Q : N×3 with same N
  assert(size(P,2)==3 && size(Q,2)==3 && size(P,1)==size(Q,1), ...
        'P,Q must be N×3 with same N');
  %find centroids
  mp = mean(P,1);  mq = mean(Q,1);
  %center points
  Pc = P - mp;     Qc = Q - mq;
  H = Pc' * Qc; % 3×3 cross-covariance
  %svd
  [U,~,V] = svd(H);
  %check for reflection and computer R and t
  S = eye(3);  S(3,3) = det(V*U');
  R = V*S*U';                  % proper rotation
  t = (mq' - R*mp');           % 3×1
end
