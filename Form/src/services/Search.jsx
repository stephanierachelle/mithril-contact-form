const m = require('mithril');

var Data = {
    todos: {
        list: [],
        fetch: function() {
            m.request({
                method: "GET",
                url: "/api/v1/todos",
            })
            .then(function(items) {
                Data.todos.list = items
            })
        }
    }
}

var Todos = {
    oninit: Data.todos.fetch,
    view: function(vnode) {
        return Data.todos.list.map(function(item) {
            return m("div", item.title)
        })
    }
}

m.route(document.body, "/", {
    "/": Todos
})