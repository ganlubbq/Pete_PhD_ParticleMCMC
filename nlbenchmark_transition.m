function [ new_state, prob ] = nlbenchmark_transition( model, kk, state, new_state )
%NLBENCHMARK_TRANSITION Sample and/or calculate transition density for
%nonlinear benchmark.

% state is the earlier state, which has time index kk. new_state is the
% following state. prob is a log-probability.

% Sample state if not provided
if (nargin<4)||isempty(new_state)
    mn = model.beta1 * state + model.beta2 * (state/(1+state^2)) + model.beta3 * cos(1.2*kk);
    new_state = mvnrnd(mn, model.sigx);
end

% Calculate probability if required
if nargout>1
    prob = log(mvnpdf(new_state, mn, model.sigx));
else
    prob = [];
end

end

