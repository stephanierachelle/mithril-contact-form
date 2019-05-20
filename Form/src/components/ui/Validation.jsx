// src/components/ui/Validation.jsx

const m = require("mithril");


//UI
import ContactForm from "../../components/ui/Validation.jsx";

const constraints = {
    from: {
        email: true
        message: "Email not valid."
    }
};

validate({from: null}, constraints);

// => undefined

validate({from: ""}, constraints);
// => {"email": ["From is not a valid email"]}

validate({from: "nicklas@ansman"}, constraints);
// => {"email": ["From is not a valid email"]}

// Any TLD is allowed
validate({from: "nicklas@foo.faketld"}, constraints);
// => undefined

// Upper cased emails are allowed
validate({from: "NICKLAS@ANSMAN.SE"}, constraints);
// => undefined

constraints = {
  from: {
    email: {
      message: "doesn't look like a valid email"
    }
  }
};

validate({from: "foobar"}, constraints);
// => {"email": ["From doesn't look like a valid email"]}

// It allows unicode
validate({from: "first.läst@example.com"}, constraints);
// => undefined
