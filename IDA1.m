minSupport = 0.2;  
minConfidence = 0.6;

rng(1);
items = {'keyboard','mouse','monitor','headphones','pc','router'};
numTrans = 200;
T = cell(numTrans,1);
for i=1:numTrans
    pick = rand(1,numel(items)) < [0.4 0.5 0.2 0.3 0.25 0.15];
    T{i} = items(pick);
end

numItems = numel(items);
X = false(numTrans,numItems);
for i=1:numTrans
    for j=1:numItems
        X(i,j) = ismember(items{j}, T{i});
    end
end

supportCounts = sum(X)/numTrans;
freqItems = find(supportCounts >= minSupport);

fprintf('Часті одиничні елементи (support >= %.2f):\n', minSupport);
for k=freqItems
    fprintf('  %s: %.3f\n', items{k}, supportCounts(k));
end

rules = {};
idx = 0;

pairs = nchoosek(1:numItems,2);
for p=1:size(pairs,1)
    a = pairs(p,1); b = pairs(p,2);
    sup = sum(X(:,a) & X(:,b))/numTrans;
    if sup >= minSupport
        
        conf = sum(X(:,a) & X(:,b)) / sum(X(:,a));
        lift = conf / supportCounts(b);
        if conf >= minConfidence
            idx = idx+1;
            rules{idx} = struct('ante',{items{a}}, 'cons',{items{b}}, ...
                'support',sup, 'confidence',conf, 'lift',lift);
        end
        
        conf = sum(X(:,a) & X(:,b)) / sum(X(:,b));
        lift = conf / supportCounts(a);
        if conf >= minConfidence
            idx = idx+1;
            rules{idx} = struct('ante',{items{b}}, 'cons',{items{a}}, ...
                'support',sup, 'confidence',conf, 'lift',lift);
        end
    end
end

fprintf('\nЗнайдені правила (support, confidence, lift):\n');
for r=1:numel(rules)
    fprintf('%s => %s : sup=%.3f, conf=%.3f, lift=%.3f\n', ...
        rules{r}.ante{1}, rules{r}.cons{1}, rules{r}.support, rules{r}.confidence, rules{r}.lift);
end