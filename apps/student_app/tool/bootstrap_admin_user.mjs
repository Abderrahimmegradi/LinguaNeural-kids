import { initializeApp } from 'firebase/app';
import {
  createUserWithEmailAndPassword,
  getAuth,
  signInWithEmailAndPassword,
  updateProfile,
} from 'firebase/auth';
import { doc, getFirestore, serverTimestamp, setDoc } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyAvpGY7AygxEu5RsBbez249kIwoCRu-DvI',
  appId: '1:395160022558:web:11189fd4c783a6b951880f',
  messagingSenderId: '395160022558',
  projectId: 'linguaneuralkids',
  authDomain: 'linguaneuralkids.firebaseapp.com',
  storageBucket: 'linguaneuralkids.firebasestorage.app',
  measurementId: 'G-ENB18EBDKS',
};

const email = process.env.BOOTSTRAP_ADMIN_EMAIL || 'admin@test.com';
const password = process.env.BOOTSTRAP_ADMIN_PASSWORD || 'Admin123!';
const displayName = process.env.BOOTSTRAP_ADMIN_NAME || 'Platform Admin';

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

async function bootstrap() {
  let credential;

  try {
    credential = await createUserWithEmailAndPassword(auth, email, password);
    await updateProfile(credential.user, { displayName });
  } catch (error) {
    if (error?.code !== 'auth/email-already-in-use') {
      throw error;
    }

    credential = await signInWithEmailAndPassword(auth, email, password);
    await updateProfile(credential.user, { displayName });
  }

  await setDoc(
    doc(db, 'users', credential.user.uid),
    {
      displayName,
      email,
      role: 'admin',
      status: 'active',
      schoolId: '',
      teacherId: null,
      avatarCharacterId: 'lumi',
      totalXP: 0,
      dailyStreak: 0,
      currentEmotion: 'steady',
      evolutionStage: 'manager',
      provisioningState: 'active',
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    },
    { merge: true },
  );

  console.log(
    JSON.stringify(
      {
        uid: credential.user.uid,
        email,
        password,
        role: 'admin',
      },
      null,
      2,
    ),
  );
}

bootstrap().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});