// src/components/layout/NavBar.jsx

const m = require("mithril");

import NavButton from "../ui/NavButton.jsx";

const NavContainer = {
  view: () => (
    <div class="nav-container">
      <NavButton path={`contact`} class="ui-button" />
    </div>
  )
};

export default NavContainer;