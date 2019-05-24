const m = require('mithril');

var Test= {
    oninit: function(vnode) {
        vnode.state.data = vnode.attrs.text },
        view: function(vnode) {
            return m("div", vnode.state.data)
        }
    }

    m(Test, {text: "Hello"})

    console.log('error');








export default ContactTwo;