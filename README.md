# Linear and Stochastic versions of the Min Cost Multi-Commodity Flow (MMCF) Problem
In the Multi-Commodity Network Flow Problem problem, a directed graph G(N,A), where N a set of nodes is and A is a set of Arcs is given. A set of K commodities has to be routed on G at minimal total cost while satisfying the usual flow-conservation constraints at the nodes.\
<strong>Parameters</strong>
<ul>
  <li><img src="https://latex.codecogs.com/gif.latex?c_{ij}^{k}" title="x_{ij}^{k}" />: 	cost of assigning commodity k to arc ij</li>
  <li><img src="https://latex.codecogs.com/gif.latex?d_{ij}" title="x_{ij}^{k}" />: 	capacity of arc ij</li>
  <li><img src="https://latex.codecogs.com/gif.latex?c_{ij}^{k}" title="b_{i}^{k}" />: 	demand/supply of commodity k at node i</li>
</ul>
Decision variable
<ul>
 <li><img src="https://latex.codecogs.com/gif.latex?x_{ij}^{k}" title="x_{ij}^{k}" /> flow of commodity k on arc ij</li>
</ul>


<strong>Stochastic Multi-commodity network flow problem (Stochastic-MMCF)</strong>\
The popular Sample Average Approximation method is used to solve the stochastic MMCF. Also instances from the OR-library of min cost multi-commodity problems is used for comparison purposes.

