function [ obs, prob ] = tracking_observation( model, state, obs )
%tracking_observation Sample and/or evaluate observation density for the
%tracking model.

% prob is a log-probability.

[~, ~, R] = tracking_AQR(model);

% Calculate observation mean
mn = tracking_h(model, state);

% Sample observation if not provided
if (nargin<3)||isempty(obs)
    obs = mvnrnd(mn', R)';
end

% Calculate probability if required
if nargout>1
    
    % Resolve angle ambiguity
    dy = obs - mn;
    % Bearing
    if dy(1) > pi
        dy(1) = dy(1) - 2*pi;
    elseif dy(1) < -pi
        dy(1) = dy(1) + 2*pi;
    end
    % Elevation
    if dy(2) > pi
        dy(2) = dy(2) - 2*pi;
    elseif dy(2) < -pi
        dy(2) = dy(2) + 2*pi;
    end
    
    prob = loggausspdf(dy, zeros(size(dy)), R);
else
    prob = [];
end

end

