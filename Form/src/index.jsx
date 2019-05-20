// src/index.jsx

const m = require("mithril");
const root = document.getElementById("app");

// Components
import StageBanner from "./components/ui/StageBanner.jsx";

// Styles
import "./index.css";

import App from "./components/layout/App.jsx";


m.render(root, <App />)