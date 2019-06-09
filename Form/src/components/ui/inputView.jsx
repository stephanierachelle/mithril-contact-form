let signup = {
    controller: function () {
      return {
        form: new Form({
          name: {presence: true},
          email: {presence: true},
          message: {presence: true},
        submit: function () {
          if(!this.form.isValid()) return
          SignupAPI(this.form.data())
            .then((res) => {
              m.route("/sendForm/")})
            ["catch"]((errors) => {
              this.form.errors(errors)})
            .then(()=> m.redraw())}
      }
    },
    view: function (ctrl) {
      return m("form",
        m("input[type=text]", {
          placeholder: "Username",
          onkeypress: m.withAttr("value", ctrl.form.username),
          onchange: ctrl.form.username.isValid}),
        _.map(ctrl.form.username.errors(), (error) => {
          return m("p.error", error)}),
        m("input[type=text]", {
          placeholder: "Password",
          onkeypress: m.withAttr("value", ctrl.form.password),
          onchange: ctrl.form.password.isValid}),
        _.map(ctrl.form.password.errors(), (error) => {
          return m("p.error", error)}),
        m("textarea.fullWidth", {
          placeholder: "Confirm Password",
          onkeypress: m.withAttr("value", ctrl.form.confirmPassword),
          onchange: ctrl.form.confirmPassword.isValid}),
        _.map(ctrl.form.confirmPassword.errors(), (error) => {
          return m("p.error", error)}),
        m("button", {
          disabled: !ctrl.form.isValid(false),
          onclick: ctrl.submit.bind(ctrl)}, "Submit"))
    }
  }