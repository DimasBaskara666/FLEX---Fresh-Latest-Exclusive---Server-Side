const { GoogleAuth } = require("google-auth-library");
const auth = new GoogleAuth({
  keyFile: "./serviceaccount.json", // Path to your downloaded JSON key file
  scopes: "https://www.googleapis.com/auth/firebase.messaging",
});

async function getAccessToken() {
  const client = await auth.getClient();
  const acceesToken = await client.getAccessToken();
  return acceesToken.token;
}

getAccessToken().then(token => {
  console.log('Generated OAuth2 token:', token);
  // use this token for your Firebase request
  }).catch(error => {
    console.error('Error generating token:', error);
});

// npm install google-auth-library
