import { FeedProgress, QuizItem, QuizOptionID, QuizProgress } from "@app/types/content";

export const createQuizProgress = (
  quiz: QuizItem,
  option: QuizOptionID,
  elapsedMs: number,
  timestamp: number = Date.now()
): QuizProgress => ({
  quizId: quiz.id,
  selected: option,
  isCorrect: quiz.correct === option,
  elapsedMs,
  answeredAt: timestamp,
});

export const updateFeedStats = (
  previous: FeedProgress,
  isCorrect: boolean,
  elapsedMs: number,
  currentIndex: number
): FeedProgress => ({
  answered: previous.answered + 1,
  correct: previous.correct + (isCorrect ? 1 : 0),
  streak: isCorrect ? previous.streak + 1 : 0,
  totalTimeMs: previous.totalTimeMs + elapsedMs,
  lastSeenIndex: Math.max(currentIndex, previous.lastSeenIndex),
});

