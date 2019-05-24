// src/components/ContactForm.jsx

const m = require('mithril');


import UIButton from "./ui/UIButton.jsx";



var contactForm = {
  firstName: {
    value: '',
    error: '',
    validate() {
      contactForm.firstName.error =
        contactForm.firstName.value().length < 3 ?
          'Expected at least 3 characters' : '';
    }
  },
 
  email: "",
  message: "",


  setLastName: function(value) {
      this.lastName = value
  },
  setEmail: function(value) {
    this.email = value
},
setMessage: function(value) {
  this.message = value
},
  canSubmitIf: function() {
      return this.firstName !== "" && this.lastName !== ""
  },
  OnSubmit: function() {/*...*/},

  view: function() {
      return m(".wrapper", 
      m(".form-wrapper",
      [
        m('.stage-title', "Contact Us"),
        m('h4', "Got a question? We'd love to hear from you. Send us a message and we'll respond as soon as possible."),
        m('p', "First Name"),
          m("input[type=text]", {
              oninput: function (e) { this.setFirstName(e.target.value) },
              value: this.firstName,
          }),

          m('p', "Last Name"),
          m("input[type=text]", {
              oninput: function (e) { this.setLastName(e.target.value) },
              value: this.lastName,
          }),

          m('p', "Email Address"),
          m("input[type=text]", {
              oninput: function (e) { this.setEmail(e.target.value) },
              value: this.email,
          }),

          m('p', "Message"),
          m('textarea.fullWidth', {
              oninput: function (e) { this.setMessage(e.target.value) },
              value: this.message,
          }),
          <UIButton action={() => canSubmitIf(vnode.dom)} buttonName="Send Message" />
        ]) 
    )
  }
}




export default contactForm;