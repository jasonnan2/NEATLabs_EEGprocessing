function [new_W, new_chans]=getSparseLinks(W,chans)
% function to only select nodes which are of interest for
% NetworkVisualization
% W is 24x24 sparse logical matrix 

% Find the indices of non-zero elements
[row, col] = find(W);

% Get unique rows and columns
unique_rows = unique(row);
unique_cols = unique(col);

% Map the indices to the new matrix indices
new_row = zeros(size(row));
new_col = zeros(size(col));
for i = 1:numel(row)
    new_row(i) = find(unique_rows == row(i));
    new_col(i) = find(unique_cols == col(i));
end

% Determine the size of the new matrix
new_size = max([numel(unique_rows), numel(unique_cols)]);

% Create the new sparse logical matrix
new_W = sparse(new_row, new_col, true, new_size, new_size);
% get rid of symmetric entries
new_W = triu(new_W, 1); 
new_chans = chans(unique(col));

end
