// src/index.jsx

const m = require("mithril");
const root = document.getElementById("app");

// Components
import StageBanner from "./components/ui/StageBanner.jsx";
import MainContainer from "./components/layout/MainContainer.jsx";

// Styles
import "./index.css";


import App from "./components/layout/App.jsx";

const HomeView = main => (
    <App>
      
    </App>
  );
  
  m.route(root, "/home", {
    "/home": {
      view: () => HomeView()
    }
  });