const m = require("mithril");

const MainContainer = {
    view: ({ children }) => {
        return <div class="main-container">{children}</div>;
    }
};

export default MainContainer;

//component that we will wrap in a flexbox
// control overflow through vertical scrolling 