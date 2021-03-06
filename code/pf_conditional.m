function [ pf ] = pf_conditional( algo, model, observ, traje )
%PF_STANDARD Run a standard particle filter

N = algo.N;
K = model.K;

% Initialise arrays
pf = struct('state', cell(K,1), 'ancestor', cell(K,1), 'weight', cell(K,1), 'marg_lhood', cell(model.K,1));
pf(1).state = zeros(model.ds, N);
pf(1).ancestor = zeros(1, N);
pf(1).weight = zeros(1, N);

% First state
ind = traje.index(1);
for ii = 1:N
    if algo.pf_proposal_type == 1
        % Bootstrap
        
        if ii == ind
            % Set state for conditioned particle
            state = traje.state(:,1);
        else
            % Sample new state
            [state, ~] = model.stateprior(model);
        end
        
        % Weight
        [~, pf(1).weight(ii)] = model.observation(model, state, observ(:,1));
        
    elseif algo.pf_proposal_type == 2
        % Other
        
        if ii == ind
            % Set state for conditioned particle
            state = traje.state(:,1);
            [~, ppsl_prob] = model.stateproposal(algo, model, [], [], observ(:,1), state);
        else
            % Sample new state
            [state, ppsl_prob] = model.stateproposal(algo, model, [], [], observ(:,1));
        end
        
        % Weight
        [~, trans_prob] = model.stateprior(model, state);
        [~, obs_prob] = model.observation(model, state, observ(:,1));
        pf(1).weight(ii) = obs_prob + trans_prob - ppsl_prob;
        
    end
    
    pf(1).state(:,ii) = state;
    
end

% Loop through time
for kk = 2:K
    
    % Initialise arrays
    pf(kk).state = zeros(model.ds, N);
    pf(kk).weight = zeros(1, N);
    
    % Index of conditioned particle
    ind = traje.index(kk);
    
    % Sample ancestors
    pf(kk).ancestor([1:ind-1 ind+1:N]) = sample_weights(pf(kk-1).weight, N-1);
    pf(kk).ancestor(ind) = traje.index(kk-1);
    
    for ii = 1:N
        
        % Ancestory
        prev_state = pf(kk-1).state(:,pf(kk).ancestor(ii));
        
        if algo.pf_proposal_type == 1
            % Bootstrap
            
            if ii == ind
                % Set state for conditioned particle
                state = traje.state(:,kk);
                
            else
                % Sample new state
                [state, ~] = model.transition(model, prev_state);
            end
            
            % Weight
            [~, pf(kk).weight(ii)] = model.observation(model, state, observ(:,kk));
            
        elseif algo.pf_proposal_type == 2
            % Other
            
            if ii == ind
                % Set state for conditioned particle
                state = traje.state(:,kk);
                [~, ppsl_prob] = model.stateproposal(algo, model, prev_state, [], observ(:,kk), state);
            else
                % Sample new state
                [state, ppsl_prob] = model.stateproposal(algo, model, prev_state, [], observ(:,kk));
            end
            
            % Weight
            [~, trans_prob] = model.transition(model, prev_state, state);
            [~, obs_prob] = model.observation(model, state, observ(:,kk));
            pf(kk).weight(ii) = obs_prob + trans_prob - ppsl_prob;
            
        end
        
        pf(kk).state(:,ii) = state;
        
    end
    
    pf(kk).marg_lhood = logsumexp(pf(kk).weight');

end

end

