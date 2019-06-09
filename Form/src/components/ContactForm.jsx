import UIButton from "./ui/UIButton.jsx";

// src/components/ContactForm.jsx

const m = require('mithril');
const stream = require("mithril/stream")


const re = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/igm;


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

};



function formModel() {
  const model = {
    firstName: {
      value: stream(''),
      error: '',
      validate() {
        model.firstName.error =
          model.firstName.value().length < 3 ?
            'Expected at least 3 characters' : '';
      }
      
    },
    lastName: {
      value: stream(''),
      error: '',
      validate() {
        model.lastName.error =
          model.lastName.value().length < 3 ?
            'Expected no more than 3 characters' : '';
      }
    },
    email: {
      value: stream(''),
      error: '',
      validate() {
        model.email.error =
        model.email.value() == '' || !re.test(model.email.value())
          ? 'Please enter a valid email address': '';
           return false;
    }
    
    },
    message: {
      value: stream(''),
      error: '',
      validate() {
        model.message.error =
        model.message.value().length < 10 ? 
        'Message needs to be at Least 10 characters' : '';
        
      }
    },
  };
  

  return model;
  
}

function validateAll(model) {
  Object.keys(model).forEach((field) =>
    model[field].validate());
}

const Example = {
  view: function (vnode) {
      return m("div", "Hello, " + vnode.attrs.field)
  }
}
  


const ValidatedInput = {
  view({ attrs }) {
    return [
      m('input[type=text]', {
        className: attrs.field.error ? 'error' : '',
        value: attrs.field.value(),
        oninput: m.withAttr('value', attrs.field.value)
      }),
      m('p.errorMessage', attrs.field.error)
    ];
  }
};

const MessageValidatedInput = {
  view({ attrs }) {
    return [
      m('textarea.fullWidth', {
        className: attrs.field.error ? 'error' : '',
        value: attrs.field.value(),
        oninput: m.withAttr('value', attrs.field.value)
      }),
      m('p.errorMessage', attrs.field.error)
    ];
  }
};

function ContactForm() {
  const model = formModel();
  return {
    view() {
      return (
        m("form", {
          onsubmit(event) {
            event.preventDefault();
            validateAll(model);
            //is it working?
            contactFormHandler(model.dom);
            console.log('Validating...')
            // place data in an array
            
            //send to server
          }
        },
        
      
        m('.stage-title', "Contact Us"),
        m('h4', "Have a question? We'd love to hear from you. Send us a message and we'll respond as soon as possible."),
          m('p', 'First Name'),
          m(ValidatedInput, { field: model.firstName }),
          m('p', 'Last Name'),
          m(ValidatedInput, { field: model.lastName }),
          m('p', 'Email'),
          m(ValidatedInput, { field: model.email }),
          m('p', 'Message'),
          m(MessageValidatedInput, { field: model.message }),
          m('button[type=submit]', {
            onclick: function() { m.route.set('/users')}
          }, 'send'),
         

          )
      )
    }
  };
}





export default ContactForm;