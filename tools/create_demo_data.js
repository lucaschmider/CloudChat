// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getFirestore, doc, setDoc } from "firebase/firestore";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyAKO1c76IlLy3LOVC2q3Ei-uwFMwn51osQ",
  authDomain: "cloud-chat-fd207.firebaseapp.com",
  databaseURL: "https://cloud-chat-fd207-default-rtdb.firebaseio.com",
  projectId: "cloud-chat-fd207",
  storageBucket: "cloud-chat-fd207.appspot.com",
  messagingSenderId: "556196467528",
  appId: "1:556196467528:web:1ff377a53964862e32d97d",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

/**
 *
 * @param {string} path
 * @param {object} data
 */
async function writeCollection(path, data) {
  try {
    Object.entries(data).forEach(async function ([key, value]) {
      const docRef = await setDoc(doc(db, path, key), value);
    });
  } catch (e) {
    console.error("Error adding document: ", e);
  }
}

await writeCollection("users", {
  EmfC8HLMScfXu0pau5qCvTCJFc73: {
    name: "Max Mustermann",
  },
});

await writeCollection("rooms", {
  "4417fc91-7669-4991-94fe-4eed1f89746e": {
    name: "Lörrach",
    participants: ["EmfC8HLMScfXu0pau5qCvTCJFc73"],
    messages: [
      {
        userId: "EmfC8HLMScfXu0pau5qCvTCJFc73",
        text: "Hallo, Welt!",
        timestamp: Date.now(),
      },
    ],
  },
});
console.log("Demo data created");

process.exit(0);
