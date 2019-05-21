// src/components/layout/App.jsx

const m = require("mithril");
const entryToForm = EntryForm();

// UI
import UIButton from "../../components/ui/UIButton.jsx";

import MainStage from "./MainStage.jsx";

// Components
import StageBanner from "../../components/ui/StageBanner.jsx";
import MainContainer from "../../components/layout/MainContainer.jsx";

//form submition
import ContactForm from "../../components/ContactForm.jsx";

const WelcomeView = () => [
  <h1 class="app-title">Conference Tracker</h1>,
  <h2 class="app-greeting">Welcome</h2>,
  <span class="app-description">Track conferences and CFP dates.</span>,
  <div class="login-button">
  <UIButton action={() => } buttonName="LOGIN" />
  </div>

const FormView = () => [
  <StageBanner
    action={() => console.log(`Sending...`)}
    title="Send Message"
  />,
  <MainContainer>,
  <ContactForm />
  </MainContainer>
];

const App = {
    oncreate: vnode => {
      const mainStage = vnode.dom.querySelector(".main-stage");

    m.route(mainStage, "/", {
        "/": {
          view: () => ConferenceView()
        },
        "/contact": {
        view: () => FormView()
        }
      });
    },

  view: ({ children }) => (
    <div class="App">
      <MainStage>{children}</MainStage>
    </div>
  )
};

export default App;