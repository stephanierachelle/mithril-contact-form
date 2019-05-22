// src/components/layout/App.jsx

const m = require("mithril");



import MainStage from "./MainStage.jsx";

// Components
import StageBanner from "../../components/ui/StageBanner.jsx";
import MainContainer from "../../components/layout/MainContainer.jsx";

//form submition
import ContactForm from "../../components/ContactForm.jsx";
import NavButton from "../ui/NavButton.jsx";

const WelcomeView = () => [
  <h1 class="app-title">Capitalviz</h1>,
  <h2 class="app-greeting">Welcome to our mithril website</h2>,
  <span class="app-description">Say hey, we won't bite.</span>,
  <NavButton  
  action={() => console.log(`clicked!`)}
  buttonName="GET IN TOUCH"
  />,
  
  ];

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

    m.route(mainStage, "/", {
        "/": {
          view: () => WelcomeView()
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