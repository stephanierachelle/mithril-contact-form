// src/components/EntryForm.jsx

const m = require("mithril");

import UIButton from "./ui/UIButton.jsx";


const entryFormHandler = entryForm => {
  const formData = new FormData(entryForm);
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


  entryForm.reset();
};


const EntryForm = {
     data: {        //State of EntryForm component
        CFP: false
    },
    view: vnode => (
        <form name="contact-form" id="contact-form">
        {/* ... */}
      <label for="first-name">
        {`First Name*`}</label>
      <input id="first-name" type="text" name="name" />
      <label for="last-name">
        {`Last Name*`}</label>
      <input id="full-name" type="text" name="name" />

      <label for="email">
        {`Email Address*`}
      </label>
      <input id="email" type="text" name="email" />
      <label for="message">
        {`Message*`}
      </label>
      <input id="input-message" type="text" name="input-message"rows="4" required />

        <UIButton action={() => entryFormHandler(vnode.dom)} buttonName="SEND" />
        </form>
    )
};

export default EntryForm;