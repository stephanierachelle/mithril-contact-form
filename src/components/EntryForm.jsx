// src/components/EntryForm.jsx

const m = require("mithril");
import UIButton from "./ui/UIButton.jsx";

const EntryForm = {
    data: {
      CFP: false
    },
  view: vnode => (
    <form name="entry-form" id="entry-form">
      <label for="first-name">{`First Name`}</label>
      <input id="first-name" type="text" name="first-name" />
      <label for="last-name">{`Last name`}</label>
      <input id="last-name" type="text" name="last-name" />
      <label for="email-address">{`Email Address`}</label>
      <input id="email-address" type="text" name="email-address" />
      <label for="message">{`Message`}</label>
      <input id="message" type="text" name="message" />
      <UIButton action={() => console.log(`Saving...`)} buttonName="Send-Message" />
    </form>
  )
};

export default EntryForm;