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

//validation

const emailRegex = RegExp(/^[a-zA-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/)

const formValid = formErrors => {
  let valid = true;

  Object.values(formErrors).forEach( val => {
    val.length > 0 && (valid = false);
  });
    
  return valid;
};

 const validation = formEl => {
    this.state = {
      fname: null,
      lname: null,
      email: null,
      message: null,
      formErrors: {
        fname: "",
        lname: "",
        email: "",
        message: "",
    }
  }
};

handleSubmit = e => { //event bubble
e.preventDefault();

if(formValid(this.state.formErrors)){
  console.log(`--submiting
  First Name: ${this.state.fname}
  Last Name: ${this.state.lname}
  Email: ${this.state.email}
  Password: ${this.state.password}`
  );
} else {
  console.error("FORM INVALID - DISPLAY ERROR MESSAGE");
  }
}



handleChange = e => {
  e.preventDefault();
  const { name, value } = e.target;
  let formErrors = this.state.formErrors;
  switch (name) {
    case 'fname':
      formErrors.fname = value.length < 3 && value.length > 0 ? 'minimum 3 characters required' : "";
      break;
    case 'lname':
      formErrors.lname = value.length < 3 && value.length > 0 ? 'minimum 3 characters required' : "";
      break;
      case 'email':
      formErrors.email = emailRegex.test(value) && value.length > 0 
      ? '' 
      : 'Invalid email'
      break;
    case 'message':
      formErrors.message = value.length < 3 && value.length > 0 ? 'minimum 3 characters required' : "";
      break;
      default:
      break;
  }

  this.setState({formErrors, [name]: value }, () => console.log(this.state))

};

//validation finish

// Public view
const ContactForm = {
  
    view: vnode => (
        <form id="contact-form" name="contact-form" method="POST" action="/contact"  >
        {/* ... */}
      <label for="fname">
        {`First Name`}</label>
      <input id="first-name" type="text" name="fname" onchange={this.handleChange} />

      <label for="lname">
        {`Last Name`}</label>
      <input id="full-name" type="text" name="lname" onchange={this.handleChange} />

      <label for="email">
        {`Email Address`}
      </label>
      <input id="email" type="text" name="email" onchange={this.handleChange} />
      <label for="message">
        {`Message`}
      </label>
      <input id="input-message" type="text" name="message" onchange={this.handleChange} />
      
        <UIButton 
        action={() => contactFormHandler(vnode.dom)} 
        buttonName="SEND" />
        </form>
    )
    
};

export default ContactForm;