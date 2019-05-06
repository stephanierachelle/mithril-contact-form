const m = require("mithril");

const CardContainer = {
    view: ({ children }) => {
        return <div class="card-container">{children}</div>;
    }
};

export default CardContainer;

//component that we will wrap in a flexbox
// control overflow through vertical scrolling 