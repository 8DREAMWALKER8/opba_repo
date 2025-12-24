const SECURITY_QUESTIONS = [
  { id: "q1", tr: "İlk evcil hayvanınızın adı nedir?", en: "What was the name of your first pet?" },
  { id: "q2", tr: "Annenizin kızlık soyadı nedir?", en: "What is your mother's maiden name?" },
  { id: "q3", tr: "İlkokul öğretmeninizin adı nedir?", en: "What is the name of your primary school teacher?" },
  { id: "q4", tr: "Doğduğunuz şehir neresi?", en: "What city were you born in?" },
];

function getQuestionText(id, lang = "tr") {
  const q = SECURITY_QUESTIONS.find((x) => x.id === id);
  if (!q) return null;
  return lang === "en" ? q.en : q.tr;
}

module.exports = { SECURITY_QUESTIONS, getQuestionText };
