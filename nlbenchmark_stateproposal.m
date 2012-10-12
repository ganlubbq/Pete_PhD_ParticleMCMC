function [ state, prob ] = nlbenchmark_stateproposal( algo, model, kk, prior_mn, prior_vr, next_state, observ, state )
%NLBENCHMARK_STATEPROPOSAL Sample and/or calculate proposal density for
%nonlinear benchmark.

% Point to linearise about
lin_state = prior_mn;

% Linearise
F = model.beta1 + model.beta2 * ( (1-lin_state^2)/(1+lin_state^2)^2 );
H = 0.05 * model.alpha * lin_state * (lin_state^2)^(model.alpha/2 - 1);

% Create "augmented observation"
if ~isempty(next_state) && ~isempty(observ)
    aug_obs = [next_state; observ];
    aug_mn = [nlbenchmark_f(model, kk, lin_state); nlbenchmark_h(model, lin_state)];
    aug_trans = [F; H];
    aug_vr = [model.sigx 0; 0 model.sigy];
elseif isempty(next_state) && ~isempty(observ)
    aug_obs = observ;
    aug_mn = nlbenchmark_h(model, lin_state);
    aug_trans = H;
    aug_vr = model.sigy;
elseif ~isempty(next_state) && isempty(observ)
    aug_obs = next_state;
    aug_mn = nlbenchmark_f(model, kk, lin_state);
    aug_trans = F;
    aug_vr = model.sigx;
end

% KF update
[ppsl_mn, ppsl_vr] = ekf_update1(prior_mn, prior_vr, aug_obs, aug_trans, aug_vr, aug_mn);

% Sample state if not provided
if (nargin<8)||isempty(state)
    state = mvnrnd(ppsl_mn, ppsl_vr);
end

% Calculate probability if required
if nargout>1
    prob = log(mvnpdf(state, ppsl_mn, ppsl_vr));
else
    prob = [];
end

end

