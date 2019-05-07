// src/components/layout/App.jsx

const m = require("mithril");

import MainStage from "./MainStage.jsx";
import NavBar from "./NavBar.jsx";


// Components
import StageBanner from "../../components/ui/StageBanner.jsx";
import MainContainer from "./MainContainer.jsx";

//form submition
import EntryForm from "../../components/EntryForm.jsx";
const HomeView = main => (
    
      <StageBanner
        action={() => console.log(`Logging out!`)}
        title="Conferences"
      />,
      <MainContainer />
  );

const FormView = () => [
  <StageBanner
    action={() => console.log(`Sending...`)}
    title="Send Message"
  />,
  <MainContainer>
  <EntryForm />
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
          view: () => HomeView()
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