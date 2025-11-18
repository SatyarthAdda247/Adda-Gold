export type QuizOptionID = "A" | "B" | "C" | "D";

export interface QuizItem {
  id: string;
  category: string;
  difficulty: "easy" | "medium" | "hard";
  question: string;
  options: Record<QuizOptionID, string>;
  correct: QuizOptionID;
  explanation?: string;
}

export interface ReelItem {
  id: string;
  title: string;
  videoUrl: string;
  thumbnailUrl?: string;
  source?: string;
  durationSec?: number;
}

export interface QuizProgress {
  quizId: string;
  selected: QuizOptionID;
  isCorrect: boolean;
  answeredAt: number;
  elapsedMs: number;
}

export interface FeedProgress {
  lastSeenIndex: number;
  streak: number;
  answered: number;
  correct: number;
  totalTimeMs: number;
}

