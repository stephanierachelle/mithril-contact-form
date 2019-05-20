// src/components/layout/App.jsx

const m = require("mithril");
const validate = require("validate.js");

import MainStage from "./MainStage.jsx";
import NavBar from "./NavBar.jsx";

// Components
import StageBanner from "../../components/ui/StageBanner.jsx";
import MainContainer from "../../components/layout/MainContainer.jsx";

//form submition
import ContactForm from "../../components/ContactForm.jsx";

const ConferenceView = conferences => (
    
      <StageBanner
        action={() => console.log(`Logging out!`)}
        title="Conferences"
      />
  );

const FormView = () => [
  <StageBanner
    action={() => console.log(`Sending...`)}
    title="Send Message"
  />,
  <MainContainer>
  <ContactForm />
  </MainContainer>
];

const App = {
    oncreate: vnode => {
      const mainStage = vnode.dom.querySelector(".main-stage");

    m.route(mainStage, "/home", {
        "/home": {
          view: () => FormView()
        },
        "/entry": {
        view: () => ConferenceView()
        }
      });
    },

  view: ({ children }) => (
    <div class="App">
      <MainStage>{children}</MainStage>
      <NavBar />
    </div>
  )
};

export default App;