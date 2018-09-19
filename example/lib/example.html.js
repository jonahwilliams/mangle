import * as IDOM from "incremental-dom";
export default function renderexample(scope) {
  IDOM.elementOpen("div")
  IDOM.elementOpen("h1")
  IDOM.text(scope.Title)
  IDOM.elementClose("h1")
  for (var index = 0; i < scope.todos.length; index++) {
    var todo = scope.todos[index];
    IDOM.elementOpen("div")
    IDOM.text(todo)
    IDOM.elementClose("div")
  }
  IDOM.elementOpenStart("button");
  IDOM.attr("onclick", scope.handleClick);
  IDOM.elementOpenEnd()
  IDOM.text("Click Me")
  IDOM.elementClose("button")
  IDOM.elementClose("div")
}
