import { initializeApp } from 'firebase/app';
import { getFirestore, writeBatch, doc, Timestamp } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyAvpGY7AygxEu5RsBbez249kIwoCRu-DvI',
  appId: '1:395160022558:web:11189fd4c783a6b951880f',
  messagingSenderId: '395160022558',
  projectId: 'linguaneuralkids',
  authDomain: 'linguaneuralkids.firebaseapp.com',
  storageBucket: 'linguaneuralkids.firebasestorage.app',
  measurementId: 'G-ENB18EBDKS',
};

const userId = 'student_demo';

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const chapters = [
  { id: 'chapter_1', title: 'Hello World', description: 'Basic greetings', order: 1, colorHex: '#0E7C86' },
  { id: 'chapter_2', title: 'My Family', description: 'Family members', order: 2, colorHex: '#1A936F' },
  { id: 'chapter_3', title: 'Colors & Shapes', description: 'Colors and shapes', order: 3, colorHex: '#F4B942' },
  { id: 'chapter_4', title: 'Numbers & Counting', description: 'Numbers 1-20', order: 4, colorHex: '#E76F51' },
  { id: 'chapter_5', title: 'Food & Drinks', description: 'Common foods', order: 5, colorHex: '#8B5CF6' },
  { id: 'chapter_6', title: 'My Body', description: 'Body parts', order: 6, colorHex: '#0E7C86' },
  { id: 'chapter_7', title: 'Daily Routine', description: 'Morning and evening actions', order: 7, colorHex: '#1A936F' },
  { id: 'chapter_8', title: 'Weather & Seasons', description: 'Weather vocabulary', order: 8, colorHex: '#F4B942' },
  { id: 'chapter_9', title: 'Animals', description: 'Pet and zoo animals', order: 9, colorHex: '#E76F51' },
  { id: 'chapter_10', title: 'Places & Directions', description: 'School, park, home', order: 10, colorHex: '#8B5CF6' },
];

const lessonTemplates = [
  { order: 1, title: 'Introduction + Vocabulary', duration: 5, xpReward: 50 },
  { order: 2, title: 'Practice + Listening', duration: 7, xpReward: 60 },
  { order: 3, title: 'Speaking + Writing', duration: 8, xpReward: 70 },
  { order: 4, title: 'Review Game', duration: 6, xpReward: 55 },
  { order: 5, title: 'Quiz', duration: 5, xpReward: 80 },
];

const topicConfig = {
  'Hello World': { keyword: 'hello', listen: 'Hello, my friend', speak: 'Hello, I am ready', write: 'hello friend', icon: 'wave' },
  'My Family': { keyword: 'mother', listen: 'This is my family', speak: 'This is my family', write: 'my family loves me', icon: 'family' },
  'Colors & Shapes': { keyword: 'circle', listen: 'The circle is blue', speak: 'The circle is red', write: 'a square is green', icon: 'shape' },
  'Numbers & Counting': { keyword: 'ten', listen: 'I can count to ten', speak: 'I can count to twenty', write: 'i count to ten', icon: 'numbers' },
  'Food & Drinks': { keyword: 'juice', listen: 'I like apple juice', speak: 'I like bread and milk', write: 'i drink orange juice', icon: 'food' },
  'My Body': { keyword: 'hand', listen: 'Raise your hand', speak: 'These are my eyes', write: 'my hands are clean', icon: 'body' },
  'Daily Routine': { keyword: 'wake up', listen: 'I wake up early', speak: 'I brush my teeth', write: 'i wake up early', icon: 'clock' },
  'Weather & Seasons': { keyword: 'rainy', listen: 'Today is rainy', speak: 'It is sunny today', write: 'winter is cold', icon: 'weather' },
  Animals: { keyword: 'lion', listen: 'The lion is strong', speak: 'The tiger is fast', write: 'the rabbit can jump', icon: 'animal' },
  'Places & Directions': { keyword: 'school', listen: 'Go to school', speak: 'The park is near home', write: 'go to the park', icon: 'map' },
};

function buildExercises(chapterId, chapterTitle, lessonId) {
  const topic = topicConfig[chapterTitle];
  const writingWords = topic.write.split(' ').map((value) => ({ label: value, value }));

  return [
    {
      id: `${lessonId}_01_multipleChoice`,
      lessonId,
      type: 'multipleChoice',
      question: `Choose the English word linked to ${chapterTitle}.`,
      questionArabic: `Select the English keyword for ${chapterTitle}.`,
      expectedSpeech: topic.keyword,
      correctAnswer: topic.keyword,
      explanation: 'This introduces the main vocabulary for the chapter.',
      xpReward: 10,
      options: [
        { label: topic.keyword, value: topic.keyword, emoji: topic.icon },
        { label: 'Maybe', value: 'maybe', emoji: 'question' },
        { label: 'Later', value: 'later', emoji: 'later' },
        { label: 'Nothing', value: 'nothing', emoji: 'none' },
      ],
      audioUrl: null,
      imageHint: topic.icon,
    },
    {
      id: `${lessonId}_02_listening`,
      lessonId,
      type: 'listening',
      question: `Listen and tap the phrase you hear for ${chapterTitle}.`,
      questionArabic: `Listen and choose the matching phrase for ${chapterTitle}.`,
      expectedSpeech: `Listen: ${topic.listen}`,
      correctAnswer: topic.listen,
      explanation: 'Listening builds recognition before speaking.',
      xpReward: 12,
      options: [
        { label: topic.listen, value: topic.listen, emoji: 'audio' },
        { label: 'See you soon', value: 'See you soon', emoji: 'wave' },
        { label: 'I am sleepy', value: 'I am sleepy', emoji: 'sleepy' },
        { label: 'Blue sky', value: 'Blue sky', emoji: 'sky' },
      ],
      audioUrl: `mock://${chapterId}/audio`,
      imageHint: 'speaker',
    },
    {
      id: `${lessonId}_03_matching`,
      lessonId,
      type: 'matching',
      question: 'Match the word to the correct picture card.',
      questionArabic: 'Match the word with the correct card.',
      expectedSpeech: topic.keyword,
      correctAnswer: topic.keyword,
      explanation: 'Matching helps connect images with vocabulary quickly.',
      xpReward: 14,
      options: [
        { label: topic.keyword, value: topic.keyword, emoji: topic.icon },
        { label: 'cat', value: 'cat', emoji: 'cat' },
        { label: 'apple', value: 'apple', emoji: 'apple' },
        { label: 'sun', value: 'sun', emoji: 'sun' },
      ],
      audioUrl: null,
      imageHint: 'grid',
    },
    {
      id: `${lessonId}_04_speaking`,
      lessonId,
      type: 'speaking',
      question: `Say the key phrase for ${chapterTitle} out loud.`,
      questionArabic: `Say the main phrase for ${chapterTitle} aloud.`,
      expectedSpeech: topic.speak,
      correctAnswer: topic.speak,
      explanation: 'Speaking practice builds confidence with the chapter phrase.',
      xpReward: 16,
      options: [],
      audioUrl: null,
      imageHint: 'microphone',
    },
    {
      id: `${lessonId}_05_writing`,
      lessonId,
      type: 'writing',
      question: 'Write the phrase that fits this chapter best.',
      questionArabic: 'Write the phrase that best fits this chapter.',
      expectedSpeech: topic.write,
      correctAnswer: topic.write,
      explanation: 'Writing reinforces spelling and sentence order.',
      xpReward: 18,
      options: writingWords,
      audioUrl: null,
      imageHint: 'pencil',
    },
  ];
}

const lessons = [];
const exercises = [];

for (const chapter of chapters) {
  for (const template of lessonTemplates) {
    const lessonId = `${chapter.id}_lesson_${template.order}`;
    lessons.push({
      id: lessonId,
      title: template.title,
      chapterId: chapter.id,
      unitId: `unit_${chapter.order}`,
      order: template.order,
      duration: template.duration,
      xpReward: template.xpReward,
      level: chapter.order,
    });
    exercises.push(...buildExercises(chapter.id, chapter.title, lessonId));
  }
}

async function seed() {
  const batch = writeBatch(db);

  for (const chapter of chapters) {
    const { id, ...data } = chapter;
    batch.set(doc(db, 'chapters', id), data, { merge: true });
  }

  for (const lesson of lessons) {
    const { id, ...data } = lesson;
    batch.set(doc(db, 'lessons', id), data, { merge: true });
  }

  for (const exercise of exercises) {
    const { id, ...data } = exercise;
    batch.set(doc(db, 'exercises', id), data, { merge: true });
  }

  await batch.commit();

  console.log(JSON.stringify({
    chapters: chapters.length,
    lessons: lessons.length,
    exercises: exercises.length,
    users: 0,
    progress: 0,
    emotions: 0,
  }, null, 2));
}

seed().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});