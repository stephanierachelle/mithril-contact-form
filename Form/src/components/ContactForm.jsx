// src/components/ContactForm.jsx

const m = require('mithril')

import UIButton from "./ui/UIButton.jsx";


const contactFormHandler = contactForm => {
  const formData = new FormData(contactForm);
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


  contactForm.reset();
};

// Public view
const ContactForm = {
     data: {        //State of ContactForm component
        validation: false
    },
    view: vnode => (
        <form id="contact-form" name="contact-form" method="POST" action="/contact"  >
        {/* ... */}
      <label for="fname">
        {`First Name`}</label>
      <input id="first-name" type="text" name="name" />

      <label for="lname">
        {`Last Name`}</label>
      <input id="full-name" type="text" name="name" />

      <label for="email">
        {`Email Address`}
      </label>
      <input id="email" type="text" name="email" />
      <label for="message">
        {`Message`}
      </label>
      <input id="input-message" type="text" name="message" />
        <UIButton action={() => contactFormHandler(vnode.dom)} buttonName="SEND" />
        </form>
    )

};

export default ContactForm;