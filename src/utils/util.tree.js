function findNode(nodeId, tree) {
  for (const node of tree) {
    if (node.id === nodeId) {
      return node;
    }
    if (Array.isArray(node.children)) {
      let result = findNode(nodeId, node.children);
      if (result) {
        return result;
      }
    }
  }
}

var data = require("./tree.mock.json");

// console.log(data);

const node = findNode("03246805-c7bf-1504-3008-1f9c009cb007", [data]);

console.log("node", node);
