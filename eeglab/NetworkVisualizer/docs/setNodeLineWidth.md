## setNodeLineWidth (networkvisualizer)
Set the line width of nodes for a given networkvisualizer object.

### Syntax
```Matlab
net = setNodeLineWidth(net, k)
net = setNodeLineWidth(net, values)
net = setNodeLineWidth(net, values, categories)
net = setNodeLineWidth(net, values, categories, classname)
```

### Arguments
* ```net```: Networkvisualizer object created with function [networkvisualizer](networkvisualizer.md).
* ```k```: A scalar value specifying the line width of all nodes.
* ```values```: A scalar value or a cell array containing the node line width to be set.
* ```categories```: A vector specifying the class categories which the modifications will apply.
* ```classname```: A string that specifies which node class the given ```categories``` correspond to.

### Description
* ```net = setNodeLineWidth(net, k)``` sets the line width of all node to ```k```.
* ```net = setNodeLineWidth(net, values)``` sets the line width of every node ```i``` to the line width provided in ```values{i}```. Thus, the ```values``` should be a vector of length equal to the number of nodes. 
* ```net = setNodeLineWidth(net, values, categories)``` uses the node class categories in ```categories``` to specify which nodes to be modified. For example, ```setNodeLineWidth(net, {10, 12}, {'A', 'B'})``` sets the line width of nodes with category ```'A'``` to ```10``` and nodes with category ```'B'``` to ```12```. This type of specification allows conditional formatting of nodes with respect to the categories provided. By default, it is assumed that the categories correspond to the first node class added by the [addNodeClass](addNodeClass.md) function.
* ```net = setNodeLineWidth(net, values, categories, classname)``` uses the node class with name ```classname``` for the provided categories.

### Examples

#### Setting the node line widths

```Matlab
rng(1, 'twister'); % For reproducibility
W = [0 1 1 0 0;1 0 0 1 1;1 0 0 0 0;0 0 0 0 1;1 0 1 0 0];
net = networkvisualizer(W);
net = setNodeLineWidth(net, 7);
plot(net);
```
which produces:

<img src="examples/setNodeLineWidth-1.png" width="300">

#### Updating node line widths using classes

```Matlab
categories = {'M', 'L', 'K', 'M', 'M'}';
net = addNodeClass(net, categories);
net = setNodeLabels(net, {'Category M'}, 'M');
net = setNodeLineWidth(net, 9, 'M');
plot(net);
```
which produces:

<img src="examples/setNodeLineWidth-2.png" width="300">

### See Also
[networkvisualizer](networkvisualizer.md), [addNodeClass](addNodeClass.md), [setNodeLabels](setNodeLabels.md), [setNodeLineColor](setNodeLineColor.md), [setNodeLineStyle](setNodeLineStyle.md)


