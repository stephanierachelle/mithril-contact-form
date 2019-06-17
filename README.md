# mithril-contact-form
A mithril form example

<h1>Set Up</h1>
<strong>Init:</strong>

npm install

<strong>Start development server (http://localhost:8081):</strong>

npm run start

<strong>Build:</strong>

npm run build

<h1>Overall Goal:</h1>
<li> This form needs to be written and fully functional in <a href="https://mithril.js.org/index.html">Mithril</a></li>
<li> Validation function works: We need to add in that if all fields are true to submit the {data} JSON object.</li>
<li>If a validation error does occur the form cannot submit</li>

<li>Send the JSON using postgREST API to our server at... Mark to confirm.</li>
<li>Subzero setup</li>

<h1>Overview </h1>
<strong>Key software products</strong> 
<li>mithril v1</li> 
<li>mithril</li>
<li>postgREST</li>
<li>postgres</li> 
<li>node.js</li>
<li>subzero</li>

Other dependacies are listed in the package JSON.

<h1>Issues</h1> 
Have only just started learning JavaScript therefore the I'm not fully across the language.
Our current biggest issue is sending the data using the postgREST npm.

We have the validation working. This is written using Mithril to structure views and route.

<strong>A run through of the functionality if this form:</strong>
This form is written based off this tutorial: <href> https://auth0.com/blog/build-robust-apps-with-mithril-and-auth0/</href>
This form is written using m() objects in two views. One view is holds the vaidation and the second view holds what is seen on the browser.
Validation is working. The form is completed until here.

<strong>The next steps that need to be solved are:</strong>

<li>On send at line(form onSubmit) - need to send data via an async method : POST so that we can post to the server.
  </li>
<li>PostgREST needs to receive this data as a JSON and send back an email as a response to the client of Form submitted. 
  </li>
<li>
The data needs to go from the API through to subzero and Open Resty will send a response email also. 
</li>

Once the form is working...
<li>Route the form page into the existing website. </li>
<li>Go live.</li>

<h1>The result:</h1>
A working example of mithril.js connecting to postgrest.



