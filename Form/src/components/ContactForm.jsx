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

const handleAuthentication = valid => {
  const formData = new Error(valid);
  const newError ={};
}



const validateAll= model => {
  Object.keys(model).forEach((field) =>
    model[field].validate());
}

const ValidatedInput = {
  view({ attrs }) {
    return [
      m('input[type=text]', {
        className: attrs.field.error ? 'error' : '',
        value: attrs.field.value(),
        oninput(event) {
          attrs.field.value(event.target.value);
        }
      }),
      m('p.errorMessage', attrs.field.error)
    ];
  }
};

console.log(validateAll, ValidatedInput);




// Public view
const ContactForm = {
  fname: null,
  lname: null,
  email: null,
  message: null,
  formErrors: {
    fname: "",
    lname: "",
    email: "",
    message: "",
  },
    view: (vnode) => (
      <div className="wrapper">
      <div className="form-wrapper">
        <form id="contact-form" className="contact-form" >
        {/* ... */}
      <label for="fname">{`First Name`}</label>
      <input 
      id="first-name" 
      type="text" 
      name="fname" 
      onchange={() => {
        vnode.state.fname = true;
    }}
      />
      {vnode.state.fname
        ? [
            <label className="errorMessage">{`*First name must contain at least 3 characters`}</label>,
           
          ]
        : null}
     
      <label for="lname">{`Last Name`}</label>
      <input 
      id="full-name" 
      type="text" 
      name="lname" 
      />

      <label for="email">{`Email Address`}</label>
      <input 
      id="email" 
      type="text" 
      name="email"
      />
      
      <label for="message">{`Message`}</label>
      <input 
      id="input-message" 
      type="text" 
      name="message" 
      />
  
        <UIButton 
        action={() => contactFormHandler(vnode.dom)} 
        buttonName="SEND" 
        onClick={() => {
          vnode.state.error = false;
        }} />
        </form>
        </div>
        </div>
    )
    
};



export default ContactForm;