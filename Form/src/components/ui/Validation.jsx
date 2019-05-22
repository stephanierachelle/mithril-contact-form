// src/components/ui/Validation.jsx

const m = require("mithril");


//UI
import ContactForm from "../../components/ui/Validation.jsx";

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
  Message: ${this.state.message}`
  );
} else {
  console.error("FORM INVALID - DISPLAY ERROR MESSAGE");
  }
}



handleChange = e => {
  e.preventDefault();
  const { name, value } = e.target;
  let formErrors = {...this.state.formErrors};
  switch (name) {
    case 'fname':
      formErrors.fname = value.length < 3 && value.length > 0 ? 'minimum 3 characters required' : "";
      break;
    case 'lname':
      formErrors.lname = value.length < 3 && value.length > 0 ? 'minimum 3 characters required' : "";
      break;
      case 'email':
      formErrors.email = emailRegex.test(value)
      ? ""
      : 'Invalid email'
      break;
    case 'message':
      formErrors.message = value.length < 3 && value.length > 0 ? 'minimum 15 characters required' : "";
      break;
      default:
      break;
  }

  this.setState({ formErrors, [name]: value }, () => console.log(this.state))
};




//validation finish


function ContactForm () {
  const input = {
    validation: {
      value: false,
      error: '',
      validate() {
        .validation.error =
          input.validation.value().length < 10 ?
            'Expected at least 10 characters' : ''
      }
    }
  }
