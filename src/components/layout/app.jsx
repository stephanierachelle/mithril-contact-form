// src/components/layout/App.jsx

const m = require("mithril");
import MainStage from "./MainStage.jsx";

import EntryForm from "../../components/EntryForm.jsx";
// Components
import StageBanner from "../../components/ui/StageBanner.jsx";
import CardContainer from "../../components/layout/CardContainer.jsx";

const HomeView = home => (
    <App>
      <StageBanner
        action={() => console.log(`Logging out!`)}
        title="Conferences"
      />
      <CardContainer>
        {home.map(home => (
          <ConferenceCard home={home} />
        ))}
      </CardContainer>
    </App>
  );

const FormView = () => [
  <StageBanner
    action={() => console.log(`Sending...`)}
    title="Send Message"
  />,
  <CardContainer />
];

const App = {
    oncreate: vnode => {
      const mainStage = vnode.dom.querySelector(".main-stage");

    m.route(mainStage, "/home", {
        "/home": {
          view: () => HomeView()
        },
        "/entry": {
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