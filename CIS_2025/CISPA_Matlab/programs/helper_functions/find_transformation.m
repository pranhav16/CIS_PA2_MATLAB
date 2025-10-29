function [R,t] = find_transformation(P, Q)
% Map P -> Q with Q ≈ R*P + t
% P, Q : N×3
  assert(size(P,2)==3 && size(Q,2)==3 && size(P,1)==size(Q,1), ...
        'P,Q must be N×3 with same N');
  mp = mean(P,1);  mq = mean(Q,1);
  Pc = P - mp;     Qc = Q - mq;
  H = Pc' * Qc;                % 3×3 cross-covariance
  [U,~,V] = svd(H);
  S = eye(3);  S(3,3) = det(V*U');
  R = V*S*U';                  % proper rotation
  t = (mq' - R*mp');           % 3×1
end
