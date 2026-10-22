classdef networkvisualizer_c < handle

    properties
        W = sparse(1, 1);
        nNode = 0;
        NodeTypes = {};
        NodeTypeIndices = {};
        NodeProperties = struct();
        EdgeProperties = struct();
    end

    methods
        function obj = networkvisualizer_c()
            obj = initialize(obj);
        end

        function obj = initialize(obj)
        end

        function obj = addNodes(obj, nodes, types)
           applyForEach = false;
           if(iscell(nodes) && (length(nodes) == length(types)) ...
               && ~isscalar(types))
               applyForEach = true;
           end
           if(applyForEach)
               for iType = 1:length(types)
                   type = types{iType};
                   nodes_subset = nodes{iType};
                   obj = performAddNodes(obj, type, nodes_subset);
               end
           else
               obj = performAddNodes(obj, types, nodes);
           end
        end

        function obj = addEdges(obj, Wedges, edge_types)
            if(nargin < 3); edge_types = []; end
            applyForEach = false;
            if(iscell(Wedges) && (length(Wedges) == length(edge_types)) ...
               && ~isempty(edge_types))
               applyForEach = true;
            end
            if(applyForEach)
               for iType = 1:length(edge_types)
                   type = edge_types{iType};
                   Wedge_subset = Wedges{iType};
                   obj = performAddEdges(obj, Wedge_subset, type);
               end
            else
               obj = performAddEdges(obj, Wedges, edge_types);
            end
        end

        function net = construct(obj)
            net = networkvisualizer(obj.W, 8);
            nodeTypes = cell(obj.nNode, 1);
            for iType = 1:length(obj.NodeTypes)
                indices = obj.NodeTypeIndices{iType};
                nodeTypes(indices) = obj.NodeTypes(iType);
            end
            edgeTypes = cellstr(join([nodeTypes(net.EdgeList(:, 1)) nodeTypes(net.EdgeList(:, 2))], '-'));
            net = addNodeClass(net, nodeTypes, 'NodeType');
            net = addEdgeClass(net, edgeTypes, 'EdgeType');
        end
    end

    methods (Access = private)
        function obj = performAddNodes(obj, type, node_info)
            iType = length(obj.NodeTypes) + 1;
            obj.NodeTypes{iType} = type;
            if(isscalar(node_info))
                n = node_info;
            else
                error("Invalid value of nodes.");
            end
            obj.NodeTypeIndices{iType} = obj.nNode + (1:n);
            obj.nNode = obj.nNode + n;
%             if(isscalar(nodes))
%                 n = nodes;
%             end
            obj.W(obj.nNode, obj.nNode) = 0;
        end

        function obj = performAddEdges(obj, Wedges, edge_type)
            s = split(edge_type, '-');
            if(length(s) ~= 2)
               ex = MException(...
                   'networkvisualizer_c:addedges:invalidformat', ...
                   'Format of edge types are invalids. They should be in the form of node_type1 followed by node-type2 separated by ''-''. For example, edges between node types ''A'' and ''B'' should be specified as ''A-B''.');
               throwAsCaller(ex);
            end
            type1 = s{1};
            type2 = s{2};
            [indices1] = getNodeTypeIndices(obj, type1);
            [indices2] = getNodeTypeIndices(obj, type2);
            obj.W(indices1, indices2) = Wedges;
            if(~isequal(type1, type2))
                obj.W(indices2, indices1) = Wedges';
            end
        end

        function [indices] = getNodeTypeIndices(obj, type)
            [index] = getNodeType(obj, type);
            if(~isempty(index))
                indices = obj.NodeTypeIndices{index};
            else
                indices = 1:obj.nNode;
            end
        end

        function [classIndex] = getNodeType(obj, type)
           if(isempty(type))
               classIndex = [];
               return;
           end
           if(length(obj.NodeTypes) < 1)
               ex = MException(...
                   'networkvisualizer_c:nodetype:emptytype', ...
                   'Node types are not set. To add a node type use ''addNodes'' function.');
               throwAsCaller(ex);
           end
%            if(isempty(type)); type = obj.NodeTypes{1}; end
           [~, classIndex] = ismember(type, obj.NodeTypes);
           if(classIndex == 0)
               ex = MException(...
                   'networkvisualizer_c:nodetype:notfound', ...
                   sprintf('Node type %s is not found.', type));
               throwAsCaller(ex);
           end
        end
    end
end