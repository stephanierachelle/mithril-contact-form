// src/components/ContactForm.jsx

const m = require('mithril');
import UIButton from "./ui/UIButton.jsx";

var ContactForm = {
  firstName: "",
  lastName: "",
  email: "",
  message: "",
  setUsername: function(value) {
      this.firstName = value
  },
  setPassword: function(value) {
      this.lastName = value
  },
  canSubmit: function() {
      return this.username !== "" && this.password !== ""
  },
  login: function() {/*...*/},
  view: function() {
      return m(".wrapper", 
      m(".form-wrapper",
      [
          m("input[type=text]", {
              oninput: function (e) { this.setUsername(e.target.value) },
              value: this.firstName,
          }),
          m("input[type=text]", {
              oninput: function (e) { this.setPassword(e.target.value) },
              value: this.lastName,
          }),
          <UIButton action={() => console.log(`Saving...`)} buttonName="SEND" />
        ]) 
        console.log("hi")
      
    )
  }
}



export default ContactForm;