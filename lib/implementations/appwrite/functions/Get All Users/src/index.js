const sdk = require("node-appwrite");

/*
  'req' variable has:
    'headers' - object with request headers
    'payload' - object with request body data
    'env' - object with environment variables

  'res' variable has:
    'send(text, status)' - function to return text response. Status code defaults to 200
    'json(obj, status)' - function to return JSON response. Status code defaults to 200

  If an error is thrown, a response with code 500 will be returned.
*/

module.exports = async function (req, res) {
  const client = new sdk.Client();
  let users = new sdk.Users(client);

  if (
    !req.env["APPWRITE_FUNCTION_ENDPOINT"] ||
    !req.env["APPWRITE_FUNCTION_API_KEY"]
  ) {
    console.warn(
      "Environment variables are not set. Function cannot use Appwrite SDK.",
    );
  } else {
    client
      .setEndpoint(req.env["APPWRITE_FUNCTION_ENDPOINT"])
      .setProject(req.env["APPWRITE_FUNCTION_PROJECT_ID"])
      .setKey(req.env["APPWRITE_FUNCTION_API_KEY"])
      .setSelfSigned(true);
  }

  const initialRequest = await users.list(undefined, 100);
  const allUsers = [...initialRequest.users];
  let retrievedUserCount = allUsers.length;

  while (retrievedUserCount < initialRequest.total) {
    const newBatch = await users.list(undefined, 100, retrievedUserCount);
    allUsers.push(...newBatch.users);
  }

  res.json({
    allUsers: allUsers.map(({ $id, name }) => ({ userId: $id, name })),
  });
};
