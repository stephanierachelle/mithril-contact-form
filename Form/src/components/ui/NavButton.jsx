// src/components/ui/NavButton.jsx
const m = require("mithril");

const NavButton = {
    view: ({ attrs }) => (
        <div onclick={attrs.action}>
        <a class="ui-button" href={`#!/contact`}> 
        <span>{attrs.buttonName}</span>
        </a>
   
        </div>
      )   
};



export default NavButton;