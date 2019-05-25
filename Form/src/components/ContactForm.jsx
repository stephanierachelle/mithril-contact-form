// src/components/ContactForm.jsx

const m = require('mithril');
const stream = require("mithril/stream")



function formModel() {
  const emailRegex = RegExp(
    /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/
  )
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
        emailRegex.email.value("").length < 3 ? 
        '' : 'Invalid email';
        
      }
      
    }
  };
  return model;
}

function validateAll(model) {
  Object.keys(model).forEach((field) =>
    model[field].validate());
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

function ContactForm() {
  const model = formModel();
  return {
    view() {
      return (
        m('form', {
          onsubmit(event) {
            event.preventDefault();
            validateAll(model);
          }
        },
          m('p', 'First Name'),
          m(ValidatedInput, { field: model.firstName }),
          m('p', 'Last Name'),
          m(ValidatedInput, { field: model.lastName }),
          m('p', 'Email'),
          m(ValidatedInput, { field: model.email }),
          m('button[type=submit]', 'Validate')
        )
      );
    }
  };
}




export default ContactForm;