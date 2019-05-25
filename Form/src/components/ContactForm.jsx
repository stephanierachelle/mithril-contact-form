// src/components/ContactForm.jsx

const m = require('mithril');


import UIButton from "./ui/UIButton.jsx";

const contactFormHandler = formDOM => {
  const formData = new FormData(formDOM);
  const newEntry = {};


  Array.from(formData.entries()).map(entryValue => {
    const key = entryValue[0];
    const value = entryValue[1];

    switch (value) {
      case "false":
        newEntry[key] = false;
        break;
      case "true":
        newEntry[key] = true;
        break;
      default:
        newEntry[key] = value;
        break;
    }
  });
  
  console.log(newEntry);



};


const ContactForm = {
  firstName:false,
  lastName:"",
  email: "",
  message: "", 
 

  setFirstName: function(value) {
    this.firstName = value
    console.log('it grabs value')
  },
  
  view: (vnode) => {
      return m(".wrapper", 
      m(".form-wrapper",
      [
        m('.stage-title', "Contact Us"),
        m('h4', "Got a question? We'd love to hear from you. Send us a message and we'll respond as soon as possible."),
        m('p', "First Name"),
          m("input[type=text]",
          {
            
            oninput: (e)=> { this.setFirstName(e.target.value) },
            value: this.firstName,
          }),


          m('p', "Last Name"),
          m("input[type=text]", {
            oninput: (e)=> { this.setLastName(e.target.value) },
              value: this.lastName,
          }),

          m('p', "Email Address"),
          m("input[type=text]", {
            oninput: (e)=> { this.setEmail(e.target.value) },
              value: this.email,
          }),
          

          m('p', "Message"),
          m('textarea.fullWidth', {
            oninput: (e)=> { this.setMessage(e.target.value) },
              value: this.message,
          }),

        < UIButton 
        action={() => contactFormHandler(vnode.dom)} 
        buttonName="Send Message" ></UIButton>
        ]) 
    )
  }
}




export default ContactForm;